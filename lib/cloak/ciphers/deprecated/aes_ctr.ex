defmodule Cloak.Cipher.Deprecated.AES.CTR do
  @moduledoc """
  DEPRECATED version of the `Cloak.Cipher.AES.CTR` cipher, for use in
  migrating existing data to the new format used by `Cloak.Cipher.AES.CTR`.

  ## Rationale

  The old `Cloak.AES.CTR` cipher used the following format for ciphertext:

      +---------------------------------------------------------+----------------------+
      |                         HEADER                          |         BODY         |
      +----------------------+------------------+---------------+----------------------+
      | Module Tag (n bytes) | Key Tag (1 byte) | IV (16 bytes) | Ciphertext (n bytes) |
      +----------------------+------------------+---------------+----------------------+

  The new `Cloak.Cipher.AES.CTR` implementation no longer prepends the "Module Tag"
  component, and uses a new format as described in its docs. This cipher can
  assist in upgrading old ciphertext to the new format.

  See the [Upgrading from 0.6.x](0.6.x_to_0.7.x.html) guide for usage.
  """

  @behaviour Cloak.Cipher

  @deprecated "Use Cloak.Cipher.AES.CTR.encrypt/2 instead. This call will raise an error."
  @impl Cloak.Cipher
  def encrypt(_plaintext, _opts) do
    raise RuntimeError,
          "#{inspect(__MODULE__)} is deprecated, and can only be used for decryption"
  end

  @impl Cloak.Cipher
  def decrypt(ciphertext, opts) do
    key = Keyword.fetch!(opts, :key)

    with true <- can_decrypt?(ciphertext, opts),
         <<iv::binary-16, ciphertext::binary>> <-
           String.replace_leading(ciphertext, tag(opts), <<>>) do
      state = :crypto.stream_init(:aes_ctr, key, iv)
      {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
      {:ok, plaintext}
    else
      _other ->
        :error
    end
  end

  @impl Cloak.Cipher
  def can_decrypt?(ciphertext, opts) do
    String.starts_with?(ciphertext, tag(opts))
  end

  @impl Cloak.Cipher
  def version(opts) do
    Keyword.fetch!(opts, :tag)
  end

  defp tag(opts) do
    Keyword.fetch!(opts, :module_tag) <> Keyword.fetch!(opts, :tag)
  end
end
