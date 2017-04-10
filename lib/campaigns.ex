defmodule MailerLite.Campaigns do
  @moduledoc """
  Get, create, delete and manage your email campaigns.
  """

  @endpoint "https://api.mailerlite.com/api/v2/campaigns"
  @headers ["X-MailerLite-ApiKey": Application.get_env(:mailerlite, :key)]

  @type campaign :: %{clicked: action,
                      date_created: String.t,
                      date_send: String.t,
                      id: non_neg_integer,
                      name: String.t,
                      opened: action,
                      status: String.t,
                      total_recipients: non_neg_integer,
                      type: String.t}
  @type action :: %{count: non_neg_integer, rate: non_neg_integer}

  @spec get() :: {:ok, [campaign]} | {:error, atom}
  def get do
    do_get(:sent)
  end

  @doc ~S"""
  Returns all campaigns you have in your account by status.

  Valid statuses:
  - `:sent`
  - `:outbox`
  - `:draft`

  When using `get/0` the `:sent` (default) status is used.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg)](https://developers.mailerlite.com/reference#campaigns-by-type)

  ## Example requests

      MailerLite.Campaigns.get
      MailerLite.Campaigns.get(:draft)

  ## Example response

      {:ok, [%{clicked: %{count: 2, rate: 40},
               date_created: "2016-02-17 15:22:40",
               date_send: "2016-02-17 15:28:40",
               id: 2825239,
               name: "Email campaign example",
               opened: %{count: 1, rate: 20},
               status: "sent",
               total_recipients: 35,
               type: "regular"}]}

  ## Errors

  If using anything other than a valid status `atom`:
      {:error, :invalid_status}

  If there's a problem connecting to the MailerLite API:
      {:error, :network_error}

  If you have provided an invalid API key:
      {:error, :auth_invalid}

  ## Tests

      iex> {:ok, response} = MailerLite.Campaigns.get
      iex> is_list(response)
      true

      iex> {:error, :invalid_status} = MailerLite.Campaigns.get("4092739")
      {:error, :invalid_status}
  """
  @spec get(atom) :: {:ok, [campaign]} | {:error, atom}
  def get(status) when status in [:sent, :outbox, :draft] do
    do_get(status)
  end

  def get(_status) do
    {:error, :invalid_status}
  end

  defp do_get(status) do
    url = @endpoint <> "/" <> Atom.to_string(status)
    case HTTPoison.get(url, @headers) do
      {:ok, response} ->
        campaigns = response
        |> Map.get(:body)
        |> Poison.decode!(as: %{})
        {:ok, campaigns}
      _ ->
        {:error, :network_error}
    end
  end
end
