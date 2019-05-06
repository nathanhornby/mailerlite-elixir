defmodule MailerLite.Groups do
  @moduledoc """
  Get, create and manage subscriber groups.
  """

  @type group :: %{active: non_neg_integer,
                        bounced: non_neg_integer,
                        clicked: non_neg_integer,
                        date_created: String.t,
                        date_updated: String.t,
                        id: non_neg_integer,
                        junk: non_neg_integer,
                        name: String.t,
                        opened: non_neg_integer,
                        sent: non_neg_integer,
                        total: non_neg_integer,
                        unconfirmed: non_neg_integer,
                        unsubscribed: non_neg_integer}

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
      MailerLite.Groups.add_subscriber(24992054, new_subscriber)

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
      iex>                    email: "burner@mailinator.com",
      iex>                    fields: %{company: "Megacorp Ltd", city: "London"},
      iex>                    name: "James McBurner",
      iex>                    resubscribe: false,
      iex>                    type: "unconfirmed"}
      iex> {:ok, subscriber} = MailerLite.Groups.add_subscriber(24992054, new_subscriber)
      iex> is_map(subscriber)
      true

      iex> MailerLite.Groups.add_subscriber(0000001, %{})
      {:error, :not_found}

      iex> MailerLite.Groups.add_subscriber("24992054", "name@domain.tld")
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
  Delete a subscriber group.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#delete-group)

  ## Example request

      MailerLite.Groups.delete(123456)

  ## Example response

      {:ok, %{"success" => true}}

  ## Tests

      iex> {:ok, response} = MailerLite.Groups.new("Test group")
      iex> group_id = Map.get(response, "id")
      iex> MailerLite.Groups.delete(group_id)
      {:ok, %{"success" => true}}

      iex> MailerLite.Groups.new(000001)
      {:error, :invalid_argument}

  """

  @spec delete(MailerLite.id) :: {:ok, map} | {:error, atom}
  def delete(group) when is_integer(group) do
    url = @endpoint <> "/" <> Integer.to_string(group)
    MailerLite.delete(url)
  end

  def delete(_campaign), do: {:error, :invalid_argument}

  @doc ~S"""
  Gets a list of all subscriber groups.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#groups)

  ## Example request

      MailerLite.Groups.get

  ## Example response

      {:ok, [[%{active: 1,
                bounced: 0,
                clicked: 0,
                date_created: "2016-04-04 11:02:33",
                date_updated: "2016-04-04 11:02:33",
                id: 3640549,
                junk: 0,
                name: "Test group",
                opened: 0,
                sent: 0,
                total: 1,
                unconfirmed: 0,
                unsubscribed: 0},
              %{active: 1,
                bounced: 0,
                clicked: 0,
                date_created: "2016-04-04 11:02:33",
                date_updated: "2016-04-04 11:02:33",
                id: 3640549,
                junk: 0,
                name: "Test group 2",
                opened: 0,
                sent: 0,
                total: 1,
                unconfirmed: 0,
                unsubscribed: 0}]}

  ## Tests

      iex> {:ok, response} = MailerLite.Groups.get
      iex> is_list(response)
      true

  """

  @spec get() :: {:ok, [MailerLite.group]} | {:error, atom}
  def get do
    url = @endpoint
    MailerLite.get(url)
  end

  @doc ~S"""
  Gets a subscriber group.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#single-group)

  ## Example request

      MailerLite.Groups.get(3640549)

  ## Example response

      %{active: 1,
        bounced: 0,
        clicked: 0,
        date_created: "2016-04-04 11:02:33",
        date_updated: "2016-04-04 11:02:33",
        id: 3640549,
        junk: 0,
        name: "Test group",
        opened: 0,
        sent: 0,
        total: 1,
        unconfirmed: 0,
        unsubscribed: 0},

  ## Tests

      iex> {:ok, response} = MailerLite.Groups.get(24992054)
      iex> is_map(response)
      true

      iex> MailerLite.Groups.get(0000001)
      {:error, :not_found}

      iex> MailerLite.Groups.get("group")
      {:error, :invalid_argument}

  """

  @spec get(MailerLite.id) :: {:ok, MailerLite.group} | {:error, atom}
  def get(group) when is_integer(group) do
    url = @endpoint <> "/" <> Integer.to_string(group)
    MailerLite.get(url)
  end

  def get(_group), do: {:error, :invalid_argument}

  @doc ~S"""
  Create a new subscriber group.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#create-group)

  ## Example request

      MailerLite.Groups.new("Test group")

  ## Example response

      %{active: 1,
        bounced: 0,
        clicked: 0,
        date_created: "2016-04-04 11:02:33",
        date_updated: "2016-04-04 11:02:33",
        id: 3640549,
        junk: 0,
        name: "Test group",
        opened: 0,
        sent: 0,
        total: 1,
        unconfirmed: 0,
        unsubscribed: 0},

  ## Tests

      iex> {:ok, response} = MailerLite.Groups.new("Test group")
      iex> group_id = Map.get(response, "id")
      iex> MailerLite.Groups.delete(group_id)
      iex> is_map(response)
      true

      iex> MailerLite.Groups.new(000001)
      {:error, :invalid_argument}

  """

  @spec new(String.t) :: {:ok, MailerLite.group} | {:error, atom}
  def new(group_name) when is_binary(group_name) do
    url = @endpoint
    body = %{name: group_name}
    |> Poison.encode!
    MailerLite.post(url, body)
  end

  def new(_group_name), do: {:error, :invalid_argument}

  @doc ~S"""
  Deletes a subscriber from a group.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#remove-subscriber)

  ## Example request

      MailerLite.Groups.remove_subscriber(24992054, "burner@mailinator.com")
      MailerLite.Groups.remove_subscriber(24992054, "1343965485")

  ## Example response

      {:ok}

  ## Tests

      iex> new_subscriber = %{autoresponders: false,
      iex>                    email: "burner@mailinator.com",
      iex>                    name: "James McBurner",
      iex>                    resubscribe: false,
      iex>                    type: "unconfirmed"}
      iex> MailerLite.Groups.add_subscriber(24992054, new_subscriber)
      iex> MailerLite.Groups.remove_subscriber(24992054, "burner@mailinator.com")
      {:ok}

      iex> MailerLite.Groups.remove_subscriber(0000001, "burner@mailinator.com")
      {:error, :not_found}

      iex> MailerLite.Groups.remove_subscriber("24992054", 1343965485)
      {:error, :invalid_argument}
  """
  @spec remove_subscriber(MailerLite.id, String.t) :: {:ok} | {:error, atom}
  def remove_subscriber(group, subscriber) when is_integer(group) and is_binary(subscriber) do
    url = @endpoint <> "/" <> Integer.to_string(group) <> "/subscribers/" <> subscriber
    MailerLite.delete(url)
  end

  def remove_subscriber(_group, _subscriber), do: {:error, :invalid_argument}

  @doc ~S"""
  Update a subscriber group.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#rename-group)

  ## Example request

      changes = %{name: "New name"}
      MailerLite.Groups.update(3640549, changes)

  ## Example response

      %{active: 1,
        bounced: 0,
        clicked: 0,
        date_created: "2016-04-04 11:02:33",
        date_updated: "2016-04-04 11:02:33",
        id: 3640549,
        junk: 0,
        name: "New name",
        opened: 0,
        sent: 0,
        total: 1,
        unconfirmed: 0,
        unsubscribed: 0},

  ## Tests

      iex> changes = %{name: "Test group"}
      iex> {:ok, response} = MailerLite.Groups.update(24992054, changes)
      iex> is_map(response)
      true

      iex> MailerLite.Groups.update("group", 000001)
      {:error, :invalid_argument}

  """

  @spec update(MailerLite.id, map) :: {:ok, map} | {:error, atom}
  def update(group, changes) when is_integer(group) and is_map(changes) do
    url = @endpoint <> "/" <> Integer.to_string(group)
    body = Poison.encode!(changes)
    MailerLite.put(url, body)
  end

  def update(_group, _changes), do: {:error, :invalid_argument}
end
