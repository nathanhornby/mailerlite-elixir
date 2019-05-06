defmodule MailerLite do
  @moduledoc """
  Shared types and functions used by other modules.
  """

  @headers [{"X-MailerLite-ApiKey", Application.get_env(:mailerlite, :key)},
            {"Content-Type", "application/json"}]

  @typedoc """
  MailerLite ID's are comprised of 7 `non_neg_integer`s. i.e. `6306138`
  """
  @type id :: non_neg_integer

  @typedoc """
  UNIX timestamp integer
  """
  @type unix_timestamp :: non_neg_integer

  @typedoc """
  MailerLite subscriber object
  """
  @type subscriber :: %{clicked: non_neg_integer,
                        date_created: String.t,
                        date_subscribe: String.t,
                        date_unsubscribe: String.t,
                        email: String.t,
                        fields: [%{key: String.t,
                                   type: String.t,
                                   value: String.t}],
                        id: non_neg_integer,
                        name: String.t,
                        opened: non_neg_integer,
                        sent: non_neg_integer,
                        type: String.t}

  # Internal HTTP client

  def get(url) do
    response = HTTPoison.get(url, @headers)
    process_response(response)
  end

  def post(url, body) do
    response = HTTPoison.post(url, body, @headers)
    process_response(response)
  end

  def put(url, body) do
    response = HTTPoison.put(url, body, @headers)
    process_response(response)
  end

  def delete(url) do
    response = HTTPoison.delete(url, @headers)
    process_response(response)
  end

  defp process_response(response) do
    {status, message} = response

    case status do
      :ok -> status_map(message)
      _ -> {:error, :network_error}
    end
  end

  defp status_map(message) do
    status_code = message.status_code

    case status_code do
      n when n in [200, 201] ->
        {:ok, Poison.decode!(message.body, as: %{})}
      204 ->
        {:ok}
      400 ->
        {:error, :bad_request}
      404 ->
        {:error, :not_found}
      422 ->
        {:error, :unprocessable_entity}
      500 ->
        {:error, :server_error}
      _ ->
        {:unknown, Poison.decode!(message.body, as: %{})}
    end
  end
end
