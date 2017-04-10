defmodule MailerLite.Stats do
  @moduledoc """
  Account statitistics.
  """

  @endpoint "https://api.mailerlite.com/api/v2/stats"
  @headers ["X-MailerLite-ApiKey": Application.get_env(:mailerlite, :key)]

  @type stats :: %{subscribed: non_neg_integer,
                   unsubscribed: non_neg_integer,
                   campaigns: non_neg_integer,
                   sent_emails: non_neg_integer,
                   open_rate: float,
                   click_rate: float,
                   bounce_rate: float}

  @doc ~S"""
  Gets basic stats for the account, subscriber count, click rates etc.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg)](https://developers.mailerlite.com/reference#stats)

  ## Example request

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
    case HTTPoison.get(@endpoint, @headers) do
      {:ok, response} ->
        stats = response
                |> Map.get(:body)
                |> Poison.decode!(as: %{})
        {:ok, stats}
      _ ->
        {:error, :general_error}
    end
  end
end
