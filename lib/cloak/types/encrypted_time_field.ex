defmodule Cloak.EncryptedTimeField do
  @moduledoc """
  An `Ecto.Type` to encrypt `Time` fields.

  ## Usage

      defmodule MyApp.EncryptedTimeField do
        use Cloak.EncryptedTimeField, vault: MyApp.Vault
      end
  """

  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.EncryptedField, unquote(opts)

      def cast(value), do: Ecto.Type.cast(:time, value)

      def before_encrypt(value) do
        case Ecto.Type.cast(:time, value) do
          {:ok, time} -> to_string(time)
          _error -> :error
        end
      end

      def after_decrypt(value) do
        case Time.from_iso8601(value) do
          {:ok, time} -> time
          _error -> :error
        end
      end
    end
  end
end
