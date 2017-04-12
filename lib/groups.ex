defmodule MailerLite.Groups do
  @moduledoc """
  Subscriber groups.
  """

  @endpoint "https://api.mailerlite.com/api/v2/groups"
  @headers [{"X-MailerLite-ApiKey", Application.get_env(:mailerlite, :key)},{"Content-Type", "application/json"}]

  @doc ~S"""
  Adds a new subscriber to a group.

  TODO Use ELixir native `Date`

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#add-single-subscriber)

  ## Example request

      new_subscriber = %{autoresponders: false,
                         email: "james.moon.fake@gmail.com",
                         fields: %{company: "Megacorp Ltd",
                                    city: "London"},
                         name: "James Moon",
                         resubscribe: false,
                         type: "unconfirmed"
                         }
      MailerLite.Groups.add_subscriber(2345678, new_subscriber)

  ## Example response

      %{clicked: 0,
        date_created: "2017-06-01",
        email: "james.moon.fake@gmail.com",
        fields: %{company: "Megacorp Ltd"
                  city: "London"},
        id: 1343965485,
        name: "James Moon",
        opened: 0,
        sent: 0,
        type: "unconfirmed"}

  ## Tests

      iex> new_subscriber = %{autoresponders: false,
      iex>                    email: "james.fakefake@googlemail.com",
      iex>                    fields: %{company: "Megacorp Ltd", city: "London"},
      iex>                    name: "James Moon",
      iex>                    resubscribe: false,
      iex>                    type: "unconfirmed"}
      iex> {:ok, subscriber} = MailerLite.Groups.add_subscriber(6322190, new_subscriber)
      iex> is_map(subscriber)
      true

      iex> MailerLite.Groups.add_subscriber(0000001, %{})
      {:error, :not_found}

      iex> MailerLite.Groups.add_subscriber("6322190", "name@domain.tld")
      {:error, :invalid_argument}
  """
  @spec add_subscriber(MailerLite.id, struct) :: {:ok, MailerLite.subscriber} | {:error, atom}
  def add_subscriber(group, new_subscriber) when is_integer(group) and is_map(new_subscriber) do
    url = @endpoint <> "/" <> Integer.to_string(group) <> "/subscribers"
    body = Poison.encode!(new_subscriber)
    case HTTPoison.post(url, body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body, as: %{})}
      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, :invalid_email}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, :server_error}
      {_, %HTTPoison.Response{status_code: code, body: body}} ->
        {code, body}
      _ ->
        {:error, :network_error}
    end
  end

  def add_subscriber(_group, _subscriber), do: {:error, :invalid_argument}
end
