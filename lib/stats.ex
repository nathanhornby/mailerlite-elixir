defmodule MailerLite.Stats do
  @moduledoc """
  Account statitistics.
  """

  @type unix_timestamp :: non_neg_integer

  @type stats :: %{subscribed: non_neg_integer,
                   unsubscribed: non_neg_integer,
                   campaigns: non_neg_integer,
                   sent_emails: non_neg_integer,
                   open_rate: float,
                   click_rate: float,
                   bounce_rate: float}

  @endpoint "https://api.mailerlite.com/api/v2/stats"
  @headers ["X-MailerLite-ApiKey": Application.get_env(:mailerlite, :key)]

  @spec get() :: {:ok, stats} | {:error, atom}
  def get do
    do_get(:now)
  end

  @doc ~S"""
  Gets basic stats for the account, subscriber count, click rates etc.

  Accepts an optional `integer` UNIX timestamp for retrieving stats for a specific time in the past.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#stats)

  ## Example requests

      MailerLite.Stats.get
      MailerLite.Stats.get(1491855902)

  ## Example response

      {:ok, %{bounce_rate: 0.05,
              campaigns: 4,
              click_rate: 0.05,
              open_rate: 0.1,
              sent_emails: 2,
              subscribed: 10187,
              unsubscribed: 1}}

  ## Tests

      iex> {:ok, response} = MailerLite.Stats.get
      iex> is_map(response)
      true

      iex> {:ok, response} = MailerLite.Stats.get(1491855902)
      iex> is_map(response)
      true
  """
  @spec get(unix_timestamp) :: {:ok, stats} | {:error, atom}
  def get(unix_timestamp) when is_integer(unix_timestamp) do
    do_get(unix_timestamp)
  end

  defp do_get(unix_timestamp) do
    url = case unix_timestamp do
      :now -> @endpoint
      _ -> @endpoint <> "?timestamp=" <> Integer.to_string(unix_timestamp)
    end
    case HTTPoison.get(url, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body, as: %{})}
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, :server_error}
      _ ->
        {:error, :network_error}
    end
  end
end
