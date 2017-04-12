defmodule MailerLite do
  @moduledoc """
  Shared types and functions used by other modules.
  """

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
end
