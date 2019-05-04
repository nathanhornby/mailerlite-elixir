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
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body, as: %{})}
      {:ok, %HTTPoison.Response{status_code: 204}} ->
        {:ok}
      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, :bad_request}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}
      {:ok, %HTTPoison.Response{status_code: 422}} ->
        {:error, :unprocessable_entity}
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, :server_error}
      {_, %HTTPoison.Response{status_code: code, body: body}} ->
        {code, body}
      _ ->
        {:error, :network_error}
    end
  end
end
