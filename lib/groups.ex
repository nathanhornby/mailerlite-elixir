defmodule MailerLite.Groups do
  @moduledoc """
  Subscriber groups.
  """

  @endpoint "https://api.mailerlite.com/api/v2/groups"

  @doc ~S"""
  Adds a new subscriber to a group.

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
    MailerLite.post(url, body)
  end

  def add_subscriber(_group, _new_subscriber), do: {:error, :invalid_argument}

  @doc ~S"""
  Deletes a subscriber from a group.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#remove-subscriber)

  ## Example request

      MailerLite.Groups.delete_subscriber(2345678, "james.moon.fake@gmail.com")
      MailerLite.Groups.delete_subscriber(2345678, "1343965485")

  ## Example response

      {:ok}

  ## Tests

      iex> new_subscriber = %{autoresponders: false,
      iex>                    email: "james.fakefake@googlemail.com",
      iex>                    name: "James Moon",
      iex>                    resubscribe: false,
      iex>                    type: "unconfirmed"}
      iex> MailerLite.Groups.add_subscriber(6322190, new_subscriber)
      iex> MailerLite.Groups.delete_subscriber(6322190, "james.fakefake@googlemail.com")
      {:ok}

      iex> MailerLite.Groups.delete_subscriber(0000001, "james.fakefake@googlemail.com")
      {:error, :not_found}

      iex> MailerLite.Groups.delete_subscriber("6322190", 1343965485)
      {:error, :invalid_argument}
  """
  @spec delete_subscriber(MailerLite.id, String.t) :: {:ok} | {:error, atom}
  def delete_subscriber(group, subscriber) when is_integer(group) and is_binary(subscriber) do
    url = @endpoint <> "/" <> Integer.to_string(group) <> "/subscribers/" <> subscriber
    MailerLite.delete(url)
  end

  def delete_subscriber(_group, _subscriber), do: {:error, :invalid_argument}
end
