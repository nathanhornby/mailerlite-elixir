defmodule MailerLite.Campaigns do
  @moduledoc """
  Get, create, delete and manage your email campaigns.
  """

  # Attributes
  @vsn 2
  @endpoint "https://api.mailerlite.com/api/v2/campaigns"
  @headers [{"X-MailerLite-ApiKey", Application.get_env(:mailerlite, :key)},{"Content-Type", "application/json"}]

  # Types
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

  @type new_campaign :: %{groups: [non_neg_integer],
                          subject: String.t,
                          type: String.t,
                          ab_settings: %{ab_win_type: String.t,
                                         send_type: String.t,
                                         split_part: String.t,
                                         winner_after: non_neg_integer,
                                         winner_after_type: String.t,
                                         values: [String.t]}}

  @type campaign_response :: %{account_id: non_neg_integer,
                               campaign_type: String.t,
                               date: String.t,
                               id: non_neg_integer,
                               mail_id: non_neg_integer,
                               options: %{campaign_type: String.t,
                                          campaign_step: String.t,
                                          date: String.t,
                                          send_type: String.t}}

  # MailerLite.get()
  @spec get() :: {:ok, [campaign]} | {:error, atom}
  def get do
    do_get(:sent)
  end

  @doc ~S"""
  Returns all campaigns you have in your account by status.

  TODO: Add sorting query params

  Valid statuses:
  - `:sent`
  - `:outbox`
  - `:draft`

  When using `get/0` the `:sent` (default) status is used.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#campaigns-by-type)

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

  def get(_status), do: {:error, :invalid_status}

  defp do_get(status) do
    url = @endpoint <> "/" <> Atom.to_string(status)
    case HTTPoison.get(url, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body, as: %{})}
      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, :bad_request}
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, :server_error}
      _ ->
        {:error, :network_error}
    end
  end

  @doc ~S"""
  Create a new campaign. Returns the new campaign details.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#campaigns)

  ## Example requests

      new_campaign = %{groups: [2984475, 3237221],
                       subject: "A regular email campaign",
                       type: "regular"}
      MailerLite.Campaigns.new(new_campaign)

  ## Example response

      {:ok, %{account_id: 441087,
              campaign_type: "regular",
              date: "2016-05-18 13:03:47",
              id: 3043021,
              mail_id: 3529037,
              options: %{campaign_type: "regular",
                         campaign_step: "step3",
                         date: "2016-05-18 13:03:47",
                         send_type: "regular"}}}

  ## Tests

      iex> new_campaign = %{groups: [6306138],
      iex>                  subject: "A regular email campaign",
      iex>                  type: "regular"}
      iex> {:ok, response} = MailerLite.Campaigns.new(new_campaign)
      iex> is_map(response)
      true

      iex> MailerLite.Campaigns.new(47)
      {:error, :invalid_argument}
  """
  @spec new(new_campaign) :: {:ok, campaign_response} | {:error, atom}
  def new(new_campaign) when is_map(new_campaign) do
    body = Poison.encode!(new_campaign)
    case HTTPoison.post(@endpoint, body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body, as: %{})}
      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, :bad_request}
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, :server_error}
      _ ->
        {:error, :network_error}
    end
  end

  def new(_campaign), do: {:error, :invalid_argument}

  @doc ~S"""
  Delete a (non scheduled) campaign.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#delete-campaign)

  ## Example requests

      MailerLite.Campaigns.delete(6345868)

  ## Example response

      {:ok}

  ## Test

      iex> new_campaign = %{groups: [6306138],
      iex>                  subject: "A regular email campaign",
      iex>                  type: "regular"}
      iex> {:ok, response} = MailerLite.Campaigns.new(new_campaign)
      iex> MailerLite.Campaigns.delete(Map.get(response, "id"))
      {:ok}
  """
  def delete(campaign) do
    url = @endpoint <> "/" <> Integer.to_string(campaign)
    case HTTPoison.delete(url, @headers) do
      {:ok, _response} -> {:ok}
      _ -> {:error, :network_error}
    end
  end
end
