defmodule MailerLite.Campaigns do
  @moduledoc """
  Get, create, delete and manage your email campaigns.
  """

  @type campaign :: %{clicked: %{count: non_neg_integer, rate: non_neg_integer},
                      date_created: String.t,
                      date_send: String.t,
                      id: non_neg_integer,
                      name: String.t,
                      opened: %{count: non_neg_integer, rate: non_neg_integer},
                      status: String.t,
                      total_recipients: non_neg_integer,
                      type: String.t}

  @type new_campaign :: %{groups: [non_neg_integer],
                          subject: String.t,
                          type: String.t,
                          ab_settings: %{ab_win_type: String.t,
                                         send_type: String.t,
                                         split_part: String.t,
                                         winner_after: non_neg_integer,
                                         winner_after_type: String.t,
                                         values: [String.t]}}

  @type new_campaign_response :: %{account_id: non_neg_integer,
                                   campaign_type: String.t,
                                   date: String.t,
                                   id: non_neg_integer,
                                   mail_id: non_neg_integer,
                                   options: %{campaign_type: String.t,
                                              campaign_step: String.t,
                                              date: String.t,
                                              send_type: String.t}}

  @type get_options :: %{limit: non_neg_integer,
                         offset: non_neg_integer,
                         order: String.t}

  @vsn 3
  @endpoint "https://api.mailerlite.com/api/v2/campaigns"
  @headers [{"X-MailerLite-ApiKey", Application.get_env(:mailerlite, :key)},{"Content-Type", "application/json"}]

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
  @spec delete(MailerLite.id) :: {:ok} | {:error, atom}
  def delete(campaign) when is_integer(campaign) do
    url = @endpoint <> "/" <> Integer.to_string(campaign)
    case HTTPoison.delete(url, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok}
      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, :bad_request}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, :server_error}
      _ ->
        {:error, :network_error}
    end
  end

  def delete(_campaign), do: {:error, :invalid_argument}

  @spec get() :: {:ok, [campaign]} | {:error, atom}
  def get do
    do_get(:sent, false)
  end

  @spec get(:sent | :outbox | :draft) :: {:ok, [campaign]} | {:error, atom}
  def get(status) when status in [:sent, :outbox, :draft] do
    do_get(status, false)
  end

  def get(_status), do: {:error, :invalid_status}

  @doc ~S"""
  Returns all campaigns you have in your account by status.

  Valid statuses:
  - `:sent`
  - `:outbox`
  - `:draft`

  When using `get/0` the `:sent` (default) status is used.

  ## Sort and paginate

  When using `get/2` you can provide a `map` of options to enable sorting and pagination:

      %{limit: 10,
        offset: 0,
        order: "DESC"} # DESC or ASC

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#campaigns-by-type)

  ## Example requests

      MailerLite.Campaigns.get
      MailerLite.Campaigns.get(:draft)
      MailerLite.Campaigns.get(:sent, %{order: "ASC"})

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

  ## Tests

      iex> {:ok, response} = MailerLite.Campaigns.get
      iex> is_list(response)
      true

      iex> {:ok, response} = MailerLite.Campaigns.get(:sent, %{order: "ASC"})
      iex> is_list(response)
      true

      iex> {:error, :invalid_argument} = MailerLite.Campaigns.get("4092739", :options)
      {:error, :invalid_argument}

      iex> {:error, :invalid_status} = MailerLite.Campaigns.get(:stared)
      {:error, :invalid_status}
  """
  @spec get(:sent | :outbox | :draft, get_options) :: {:ok, [campaign]} | {:error, atom}
  def get(status, options)
      when status in [:sent, :outbox, :draft] and is_map(options) do
    do_get(status, options)
  end

  def get(_status, _options), do: {:error, :invalid_argument}

  defp do_get(status, options) do
    url = case options do
      false -> @endpoint <> "/" <> Atom.to_string(status)
      _ ->
        options_list = Map.to_list(options)
        options_formatted = ""
        for {key, value} <- options_list do
          options_formatted <> "?" <> Atom.to_string(key) <> "=" <> value <> "&"
        end
        @endpoint <> "/" <> Atom.to_string(status) <> options_formatted
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
  @spec new(new_campaign) :: {:ok, new_campaign_response} | {:error, atom}
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
end
