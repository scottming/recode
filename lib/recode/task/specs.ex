defmodule Recode.Task.Specs do
  @moduledoc """
  Function should have specs.

  ## Options

    * `:only` - `:public`, `:visible`
    * `:macros` - when `true`, macros are also checked, defaults to `false`.
  """

  use Recode.Task, check: true

  alias Recode.Context
  alias Recode.Issue
  alias Recode.Task.Specs
  alias Rewrite.Source
  alias Sourceror.Zipper

  @impl Recode.Task
  def run(source, opts) do
    include = Keyword.get(opts, :only, :all)
    macros = Keyword.get(opts, :macros, false)

    issues = check_specs(source, {include, macros})

    Source.add_issues(source, issues)
  end

  defp check_specs(source, opts) do
    source
    |> Source.ast()
    |> Zipper.zip()
    |> Context.traverse({[], nil}, fn zipper, context, acc ->
      check_specs(zipper, context, acc, opts)
    end)
    |> result()
  end

  defp check_specs(zipper, context, {issues, last_def}, opts) do
    case context.definition != last_def do
      true ->
        issues = check_spec(opts, context, issues)
        {zipper, context, {issues, context.definition}}

      false ->
        {zipper, context, {issues, last_def}}
    end
  end

  defp check_spec(_opts, %Context{definition: nil}, issues) do
    issues
  end

  defp check_spec(_opts, %Context{definition: {{:defmacro, :__using__, _args}, _body}}, issues) do
    issues
  end

  defp check_spec({_only, false}, %Context{definition: {{kind, _name, _args}, _body}}, issues)
       when kind in [:defmacro, :defmacrop] do
    issues
  end

  defp check_spec({:all, _macros}, context, issues) do
    case not Context.spec?(context) and not Context.impl?(context) do
      true -> [issue(context) | issues]
      false -> issues
    end
  end

  defp check_spec({only, _macros}, context, issues) do
    case Context.definition?(context, only) and
           not Context.spec?(context) and
           not Context.impl?(context) do
      true -> [issue(context) | issues]
      false -> issues
    end
  end

  defp issue(%Context{definition: {_definition, meta}}) do
    message = "Functions should have a @spec type specification."
    Issue.new(Specs, message, meta)
  end

  defp result({_zipper, {issues, _seen}}), do: issues
end
