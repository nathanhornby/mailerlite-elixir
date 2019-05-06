defmodule MailerLite.Stats do
  @moduledoc """
  Account statitistics.
  """

  @typedoc """
  MailerLite stats object
  """
  @type stats :: %{subscribed: non_neg_integer,
                   unsubscribed: non_neg_integer,
                   campaigns: non_neg_integer,
                   sent_emails: non_neg_integer,
                   open_rate: float,
                   click_rate: float,
                   bounce_rate: float}

  @endpoint "https://api.mailerlite.com/api/v2/stats"

  @doc ~S"""
  Gets basic stats for the account, subscriber count, click rates etc.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#stats)

  ## Example requests

      MailerLite.Stats.get

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

  """

  @spec get() :: {:ok, stats} | {:error, atom}
  def get do
    do_get(:now)
  end

  @doc ~S"""
  The same as `MaileLite.Stats.get` but accepts an `integer` UNIX timestamp for retrieving stats for a specific time in the past.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#stats)

  ## Example requests

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

      iex> {:ok, response} = MailerLite.Stats.get(1491855902)
      iex> is_map(response)
      true

      iex> MailerLite.Stats.get("time")
      {:error, :invalid_argument}

  """

  @spec get(MailerLite.unix_timestamp) :: {:ok, stats} | {:error, atom}
  def get(unix_timestamp) when is_integer(unix_timestamp) do
    do_get(unix_timestamp)
  end

  def get(_unix_timestamp), do: {:error, :invalid_argument}

  defp do_get(unix_timestamp) do
    url = case unix_timestamp do
      :now -> @endpoint
      _ -> @endpoint <> "?timestamp=" <> Integer.to_string(unix_timestamp)
    end
    MailerLite.get(url)
  end
end
