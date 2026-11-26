from unittest import mock

import pytest
from slack_sdk import WebClient
from slack_sdk.web import SlackResponse
from django.conf import settings
from slack_sdk.errors import SlackApiError

from response.slack import client
from tests.slack.slack_payloads import user_by_email


@pytest.fixture
def slack_api_mock(monkeypatch):
    client_mock = mock.Mock(spec=WebClient)
    monkeypatch.setattr(settings.SLACK_CLIENT, "client", client_mock)
    return client_mock


@pytest.fixture
def slack_client(slack_api_mock):
    # We set the backoff ridiculously low so that we're not hanging around
    # waiting for retries in tests
    c = client.SlackClient("test-token", retry_base_backoff_seconds=0.0000001)
    c.client = slack_api_mock
    return c


def test_slack_api_call_success(slack_client, slack_api_mock):
    slack_response_mock = mock.Mock(spec=SlackResponse)
    slack_api_mock.api_call.return_value = slack_response_mock

    resp = slack_client.api_call("test_endpoint", "arg1", kwarg2="foo")
    assert resp == slack_response_mock
    slack_api_mock.api_call.assert_called_with("test_endpoint", params={'kwarg2': 'foo'})


def test_slack_api_raise_error_named(slack_client, slack_api_mock):
    slack_response_mock = mock.Mock(spec=SlackResponse)
    def mock_get(key, default):
        if key == "error":
            return "test_error"
        return default
    slack_response_mock.get.side_effect = mock_get

    slack_api_mock.api_call.side_effect = SlackApiError("test_error", response=slack_response_mock)

    with pytest.raises(client.SlackError) as e:
        slack_client.api_call("test_endpoint", "arg1", kwarg2="foo")

    assert e.value.slack_error == "test_error"
    slack_api_mock.api_call.assert_called_with("test_endpoint", params={'kwarg2': 'foo'})


def test_slack_api_raise_error_default(slack_client, slack_api_mock):
    slack_response_mock = mock.Mock(spec=SlackResponse)
    def mock_get(key, default):
        return default
    slack_response_mock.get.side_effect = mock_get

    slack_api_mock.api_call.side_effect = SlackApiError("test_error", response=slack_response_mock)

    with pytest.raises(client.SlackError) as e:
        slack_client.api_call("test_endpoint", "arg1", kwarg2="foo")

    assert e.value.slack_error == "<no error given>"
    slack_api_mock.api_call.assert_called_with("test_endpoint", params={'kwarg2': 'foo'})


def test_slack_api_call_error(slack_client, slack_api_mock):
    slack_response_mock = mock.Mock(spec=SlackResponse)
    slack_response_mock.get.side_effect = lambda key, default: {
        "ok": False,
        "error": "test_error"
    }[key]

    slack_api_mock.api_call.return_value = slack_response_mock

    with pytest.raises(client.SlackError) as e:
        slack_client.api_call("test_endpoint", "arg1", kwarg2="foo")

    assert e.value.slack_error == "test_error"
    slack_api_mock.api_call.assert_called_with("test_endpoint", params={'kwarg2': 'foo'})


def test_slack_backoff_rate_limit_succeeded(slack_client, slack_api_mock):
    expected_resp = {"ok": True, "response": "bar"}
    slack_api_mock.api_call.side_effect = [
        SlackApiError("test_error", response={"ok": False, "error": "ratelimited"}),
        {"ok": False, "error": "ratelimited"},
        {"ok": False, "error": "ratelimited"},
        SlackApiError("test_error", response={"ok": False, "error": "ratelimited"}),
        SlackApiError("test_error", response={"ok": False, "error": "ratelimited"}),
        expected_resp,
    ]

    resp = slack_client.api_call("test_endpoint", "arg1", kwarg2="foo")
    assert resp == expected_resp
    assert slack_api_mock.api_call.call_count == 6


def test_slack_backoff_rate_limit_max_retry_attempts(slack_client, slack_api_mock):
    slack_api_mock.api_call.return_value = {"ok": False, "error": "ratelimited"}

    with pytest.raises(client.SlackError) as e:
        slack_client.api_call("test_endpoint", "arg1", kwarg2="foo")

    assert e.value.slack_error == "ratelimited"
    assert slack_api_mock.api_call.call_count == 11


def test_get_user_profile_by_email(slack_client, slack_api_mock):
    slack_api_mock.api_call.return_value = user_by_email

    # request a user by email
    user = slack_client.get_user_profile_by_email("spengler@ghostbusters.example.com")

    slack_api_mock.api_call.assert_called_with(
        "users.lookupByEmail", params={'email': "spengler@ghostbusters.example.com"}
    )

    # check we get back the expected user profile
    assert user["id"] == "W012A3CDE"
    assert user["name"] == "spengler"
    assert user["fullname"] == "Egon Spengler"
    assert user["email"] == "spengler@ghostbusters.example.com"
