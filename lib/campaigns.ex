defmodule MailerLite.Campaigns do
  @moduledoc """
  Email campaigns.
  """

  @endpoint "https://api.mailerlite.com/api/v2/campaigns"
  @headers ["X-MailerLite-ApiKey": Application.get_env(:mailerlite, :key)]

  @type campaigns :: [campaign]
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

  @doc """
  Returns all campaigns you have in your account by status
  """

  @spec get() :: {:ok, campaigns} | {:error, atom}
  def get do
    do_get(:sent)
  end

  @spec get(atom) :: {:ok, campaigns} | {:error, atom}
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
        {:error, :general_error}
    end
  end
end
