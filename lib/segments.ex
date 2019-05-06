defmodule MailerLite.Segments do
  @moduledoc """
  Subscriber segments.
  """
  
  @type segments :: %{data: [%{clicked: non_neg_integer,
                               created_at: String.t,
                               filter: %{rules: [%{args: [String.t],
                                                   operator: String.t}]},
                               id: MailerLite.id,
                               opened: non_neg_integer,
                               sent: non_neg_integer,
                               title: String.t,
                               total: non_neg_integer,
                               updated_at: String.t}],
                      meta: %{pagination: %{count: non_neg_integer,
                                            current_page: non_neg_integer,
                                            links: [],
                                            per_page: non_neg_integer,
                                            total: non_neg_integer,
                                            total_pages: non_neg_integer}}}

  @endpoint "https://api.mailerlite.com/api/v2/segments"

  @doc ~S"""
  Gets all account subscriber segments.

  [![API reference](https://img.shields.io/badge/MailerLite API-→-00a154.svg?style=flat-square)](https://developers.mailerlite.com/reference#segments-1)

  ## Example requests

      options = %{limit: 100,
                  offset: 1,
                  order: "DESC"}

      MailerLite.Segments.get(options)

  ## Example response

      {:ok, %{data: [%{clicked: 0,
                       created_at: "2018-06-08 17:30:56",
                       filter: %{rules: [%{args:["8", "*@mailerlite.com"],
                                         operator:"text_field_contains"}]},
                       id: 0123456,
                       opened: 0,
                       sent: 0,
                       title: "Segment one",
                       total: 0,
                       updated_at: "2018-06-08 17:30:56"}],
              meta: %{pagination: %{count: 1,
                                    current_page: 1,
                                    links: [],
                                    per_page: 100,
                                    total: 1,
                                    total_pages: 1}}}}

  ## Tests

      iex> options = %{limit: 100, offset: 1, order: "DESC"}
      iex> {:ok, response} = MailerLite.Segments.get(options)
      iex> is_map(response)
      true

  """

  @spec get(map) :: {:ok, segments} | {:error, atom}
  def get(options) when is_map(options) do
    options_list = Map.to_list(options)
    options_formatted = ""
    for {key, value} <- options_list do
      options_formatted <> "?" <> Atom.to_string(key) <> "=" <> value <> "&"
    end
    url = @endpoint <> "/" <> options_formatted
    MailerLite.get(url)
  end

  def get(_options), do: {:error, :invalid_argument}
end
