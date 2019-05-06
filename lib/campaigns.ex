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

  @endpoint "https://api.mailerlite.com/api/v2/campaigns"

  @doc ~S"""
  Cancels a campaign which has `outbox` status.

  TODO Use Elixir native Date for input/output

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#campaign-actions-and-triggers)

  ## Example requests

      MailerLite.Campaigns.cancel(6654216)

  ## Example response

      %{account_id: 123456,
        campaign_name: "An email campaign",
        campaign_type: "regular",
        clicked: null,
        count: null,
        date: "2016-05-30 13:45:23",
        end_time: "2016-06-30 13:45:23",
        id: 1234567,
        mails: [%{code: "t4h8j0",
                  date: "2015-12-28 17:25:31",
                  from: "demo@mailerlite.com",
                  from_name: "Demo",
                  groups: [%{active: 7,
                             bounced: 0,
                             clicked: 1,
                             date: "2015-12-16 14:43:46"
                             id: 2984475,
                             junk: 0,
                             name: "Personal",
                             opened: 2,
                             ordering: 5,
                             sent: 4,
                             total: 7,
                             updated: "2016-01-29 07:45:54"
                             updating: 0,
                             unconfirmed: 0,
                             unsubscribed: 0}],
                  host: "mailerlite.com",
                  id: 2851096,
                  language: %{code: "en",
                              title: "English"},
                  send_date: "2016-09-30 15:15:00",
                  subject: "Test regular campaign",
                  type: "custom_html",
                  updated: "2016-02-04 11:55:01",
                  url: "Test-regular-campaign-2851096"}]
        mail_id: 0987543,
        opened: null,
        send_date: "2016-09-30 15:15:00",
        status: "draft",
        timezone: "120"}

  ## Tests

      iex> new_campaign = %{groups: [24992054],
      iex>                  subject: "A temporary campaign",
      iex>                  type: "regular"}
      iex> {:ok, new_response} = MailerLite.Campaigns.new(new_campaign)
      iex> campaign_id = Map.get(new_response, "id")
      iex> html = ~s(<h1>Title</h1><a href="{$unsubscribe}">Unsubscribe</a>)
      iex> plain = "Open HTML newsletter: {$url}. Unsubscribe: {$unsubscribe}"
      iex> MailerLite.Campaigns.upload_template(campaign_id, html, plain, false)
      iex> send_options = %{date: "2020-12-25 09:31",
      iex>                  type: 2}
      iex> MailerLite.Campaigns.send(campaign_id, send_options)
      iex> {:ok, response} = MailerLite.Campaigns.cancel(campaign_id)
      iex> is_map(response)
      true

      iex> MailerLite.Campaigns.cancel(0000001)
      {:error, :not_found}

      iex> MailerLite.Campaigns.cancel("47")
      {:error, :invalid_argument}
  """
  @spec cancel(MailerLite.id) :: {:ok, struct} | {:error, struct}
  def cancel(campaign) when is_integer(campaign) do
    url = @endpoint <> "/" <> Integer.to_string(campaign) <> "/actions/cancel"
    MailerLite.post(url, "")
  end

  def cancel(_campaign), do: {:error, :invalid_argument}

  @doc ~S"""
  Delete a (non scheduled) campaign.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#delete-campaign)

  ## Example requests

      MailerLite.Campaigns.delete(6345868)

  ## Example response

      {:ok}

  ## Test

      iex> new_campaign = %{groups: [24992054],
      iex>                  subject: "A regular email campaign",
      iex>                  type: "regular"}
      iex> {:ok, response} = MailerLite.Campaigns.new(new_campaign)
      iex> MailerLite.Campaigns.delete(Map.get(response, "id"))
      {:ok, %{"success" => true}}
  """
  @spec delete(MailerLite.id) :: {:ok, map} | {:error, atom}
  def delete(campaign) when is_integer(campaign) do
    url = @endpoint <> "/" <> Integer.to_string(campaign)
    MailerLite.delete(url)
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
    MailerLite.get(url)
  end

  @doc ~S"""
  Create a new campaign. Returns the new campaign details.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#campaigns)

  ## Example requests

      new_campaign = %{groups: [24992054, 25000854],
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

      iex> new_campaign = %{groups: [24992054, 25000854],
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
    MailerLite.post(@endpoint, body)
  end

  def new(_campaign), do: {:error, :invalid_argument}

  @spec send(MailerLite.id) :: {:ok, struct} | {:error, atom}
  def send(campaign) when is_integer(campaign) do
    url = @endpoint <> "/" <> Integer.to_string(campaign) <> "/actions/send"
    MailerLite.post(url, "")
  end

  def send(_campaign), do: {:error, :invalid_argument}

  @doc ~S"""
  Schedule and send a campaign that has `draft`status and has `step` value equal to `3`.

  TODO Use Elixir native Date for input/output

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#campaign-actions-and-triggers)

  ## Example requests

      MailerLite.Campaigns.send(6654216)

      send_options = %{analytics: 1,
                       date: "2017-05-01 09:31:00",
                       type: 2,
                       followup_date: "2017-05-01 09:31",
                       followup_schedule: "specific"
                       followup_timezone_id: 2}
      MailerLite.Campaigns.send(6654216, send_options)

  ## Example response

      %{account_id: 123456,
        campaign_name: "An email campaign",
        campaign_type: "regular",
        clicked: null,
        count: null,
        date: "2016-05-30 13:45:23",
        end_time: "2016-06-30 13:45:23",
        id: 1234567,
        mails: [%{code: "t4h8j0",
                  date: "2015-12-28 17:25:31",
                  from: "demo@mailerlite.com",
                  from_name: "Demo",
                  groups: [%{active: 7,
                             bounced: 0,
                             clicked: 1,
                             date: "2015-12-16 14:43:46"
                             id: 2984475,
                             junk: 0,
                             name: "Personal",
                             opened: 2,
                             ordering: 5,
                             sent: 4,
                             total: 7,
                             updated: "2016-01-29 07:45:54"
                             updating: 0,
                             unconfirmed: 0,
                             unsubscribed: 0}],
                  host: "mailerlite.com",
                  id: 2851096,
                  language: %{code: "en",
                              title: "English"},
                  send_date: "2016-09-30 15:15:00",
                  subject: "Test regular campaign",
                  type: "custom_html",
                  updated: "2016-02-04 11:55:01",
                  url: "Test-regular-campaign-2851096"}]
        mail_id: 0987543,
        opened: null,
        send_date: "2016-09-30 15:15:00",
        status: "draft",
        timezone: "120"}

  ## Tests

      iex> new_campaign = %{groups: [24992054],
      iex>                  subject: "A temporary campaign",
      iex>                  type: "regular"}
      iex> {:ok, new_response} = MailerLite.Campaigns.new(new_campaign)
      iex> campaign_id = Map.get(new_response, "id")
      iex> html = ~s(<h1>Title</h1><a href="{$unsubscribe}">Unsubscribe</a>)
      iex> plain = "Open HTML newsletter: {$url}. Unsubscribe: {$unsubscribe}"
      iex> MailerLite.Campaigns.upload_template(campaign_id, html, plain, false)
      iex> send_options = %{date: "2020-12-25 09:31",
      iex>                  type: 2}
      iex> {:ok, response} = MailerLite.Campaigns.send(Map.get(new_response, "id"), send_options)
      iex> is_map(response)
      true

      iex> MailerLite.Campaigns.send(0000001)
      {:error, :not_found}

      iex> MailerLite.Campaigns.send("campaign", 4)
      {:error, :invalid_argument}
  """
  @spec send(MailerLite.id, struct) :: {:ok, struct} | {:error, atom}
  def send(campaign, options) when is_integer(campaign) and is_map(options) do
    url = @endpoint <> "/" <> Integer.to_string(campaign) <> "/actions/send"
    body = Poison.encode!(options)
    MailerLite.post(url, body)
  end

  def send(_campaign, _options), do: {:error, :invalid_argument}

  @doc ~S"""
  Uploads an HTML and plain text template to a campaign.

  ## Important

  Your HTML template must contain an unsubscribe link:

      <a href="{$unsubscribe}">Unsubscribe</a>

  Your plain text email should contain these variables:

  - `{$unsubscribe}` : Unsubscribe link
  - `{$url}` : URL to your HTML newsletter

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#put-custom-content-to-campaign)

  ## Example request

      campaign = 3043021
      html = ~s(<h1>Title</h1><a href="{$unsubscribe}">Unsubscribe</a>)
      plain = "Open HTML newsletter: {$url}. Unsubscribe: {$unsubscribe}"
      auto_inline = false

      MailerLite.Campaigns.upload_template(campaign, html, plain, auto_inline)

  ## Example response

      {:ok}

  ## Tests

      iex> html = ~s(<h1>Title</h1><a href="{$unsubscribe}">Unsubscribe</a>)
      iex> plain = "Open HTML newsletter: {$url}. Unsubscribe: {$unsubscribe}"
      iex> MailerLite.Campaigns.upload_template(6654216, html, plain, false)
      {:ok, %{"success" => true}}

      iex> html = ~s(<h1>Title</h1>)
      iex> plain = "Open HTML newsletter: {$url}."
      iex> MailerLite.Campaigns.upload_template(6654216, html, plain, false)
      {:error, :unprocessable_entity}

      iex> MailerLite.Campaigns.upload_template("campaign", 4, :banana, 69)
      {:error, :invalid_argument}
  """
  @spec upload_template(MailerLite.id, String.t, String.t, boolean) ::
        {:ok, map} |
        {:error, atom} |
        {:error, non_neg_integer, String.t}
  def upload_template(campaign, html, plain, auto_inline)
      when is_integer(campaign)
      and is_binary(html)
      and is_binary(plain)
      and is_boolean(auto_inline) do
    body = %{html: html, plain: plain, auto_inline: auto_inline}
    |> Poison.encode!
    url = @endpoint <> "/" <> Integer.to_string(campaign) <> "/content"
    MailerLite.put(url, body)
  end

  def upload_template(_campaign, _html, _plain, _auto_inline),
    do: {:error, :invalid_argument}
end
