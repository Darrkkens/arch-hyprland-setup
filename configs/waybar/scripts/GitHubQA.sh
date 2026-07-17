#!/usr/bin/env bash

repo="Athostec-Telecom/New-Omni"
workflow="CD - Develop"
branch="develop"
user="Darrkkens"
pulls_url="https://github.com/$repo/pulls?q=is%3Apr+is%3Aopen"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
state_file="$cache_dir/github-qa.state"
pr_state_file="$cache_dir/github-prs.state"
lock_file="$cache_dir/github-qa.lock"

mkdir -p "$cache_dir"

run="$(
	gh run list \
		--repo "$repo" \
		--workflow "$workflow" \
		--branch "$branch" \
		--user "$user" \
		--limit 1 \
		--json databaseId,workflowName,displayTitle,status,conclusion,headBranch,createdAt,url \
		2>/dev/null
	)"

prs="$(
	gh pr list \
		--repo "$repo" \
		--state open \
		--limit 10 \
		--json number,title,author,headRefName,updatedAt,url,isDraft \
		2>/dev/null
)"

prs_available=true
if ! jq empty <<< "$prs" 2>/dev/null; then
	prs="[]"
	prs_available=false
fi

if [[ "$1" == "open" ]]; then
	url="$(jq -r '.[0].url // empty' <<< "$run")"
	[[ -n "$url" ]] && xdg-open "$url"
	exit 0
fi

if [[ "$1" == "prs" ]]; then
	url="$pulls_url"
	if [[ "$(jq 'length' <<< "$prs")" == "1" ]]; then
		url="$(jq -r '.[0].url // empty' <<< "$prs")"
	fi
	[[ -n "$url" ]] && xdg-open "$url"
	exit 0
fi

if [[ -z "$run" || "$(jq 'length' <<< "$run" 2>/dev/null)" == "0" ]]; then
	pr_count="$(jq 'length' <<< "$prs")"
	printf '{"text":"QA ? PR %s","tooltip":"Nenhuma execução encontrada\nPRs abertas: %s","class":"unknown"}\n' \
		"$pr_count" "$pr_count"
	exit 0
fi

status="$(jq -r '.[0].status' <<< "$run")"
conclusion="$(jq -r '.[0].conclusion // empty' <<< "$run")"
run_id="$(jq -r '.[0].databaseId' <<< "$run")"
title="$(jq -r '.[0].displayTitle' <<< "$run")"
created_at="$(jq -r '.[0].createdAt' <<< "$run")"

case "$status:$conclusion" in
	completed:success)
		icon="✓"
		class="success"
		result="Sucesso"
		;;
	completed:failure|completed:startup_failure|completed:timed_out)
		icon="✗"
		class="failure"
		result="Falhou"
		;;
	completed:cancelled)
		icon="⊘"
		class="cancelled"
		result="Cancelado"
		;;
	*)
		icon="●"
		class="running"
		result="Em execução"
		;;
esac

state="$run_id:$status:$conclusion"
pr_state="$(jq -c 'map(.number) | sort' <<< "$prs")"

(
	flock -x 9
	previous_state="$(cat "$state_file" 2>/dev/null || true)"

	if [[ -n "$previous_state" && "$previous_state" != "$state" ]]; then
		case "$class" in
			success)
				urgency="normal"
				notification_icon="emblem-default"
				;;
			failure|cancelled)
				urgency="critical"
				notification_icon="dialog-error"
				;;
			*)
				urgency="low"
				notification_icon="system-run"
				;;
		esac

		notify-send \
			--app-name="GitHub Actions" \
			--urgency="$urgency" \
			--icon="$notification_icon" \
			"New-Omni · QA: $result" \
			"$title"
	fi

	printf '%s' "$state" > "$state_file"

	if [[ "$prs_available" == "true" ]]; then
		previous_pr_state="$(cat "$pr_state_file" 2>/dev/null || true)"

		if [[ -n "$previous_pr_state" && "$previous_pr_state" != "$pr_state" ]]; then
			new_prs="$(
				jq -r --argjson previous "$previous_pr_state" '
					map(.number as $number | select(($previous | index($number)) | not)) |
					map("#" + (.number | tostring) + " " + .title + " · " + (.author.login // "sem autor")) |
					join("\n")
				' <<< "$prs"
			)"
			closed_count="$(
				jq -n --argjson previous "$previous_pr_state" --argjson current "$pr_state" \
					'$previous - $current | length'
			)"

			if [[ -n "$new_prs" ]]; then
				notify-send \
					--app-name="GitHub Pull Requests" \
					--urgency="normal" \
					--icon="emblem-documents" \
					"New-Omni · PR aberta" \
					"$new_prs"
			elif [[ "$closed_count" != "0" ]]; then
				notify-send \
					--app-name="GitHub Pull Requests" \
					--urgency="low" \
					--icon="emblem-default" \
					"New-Omni · PRs atualizadas" \
					"$closed_count PR(s) sairam da lista de abertas"
			fi
		fi

		printf '%s' "$pr_state" > "$pr_state_file"
	fi
) 9>"$lock_file"

created_local="$(date --date="$created_at" '+%d/%m/%Y %H:%M' 2>/dev/null || printf '%s' "$created_at")"
pr_count="$(jq 'length' <<< "$prs")"
if [[ "$pr_count" == "0" ]]; then
	pr_tooltip="PRs abertas: 0"
else
	pr_tooltip="$(
		jq -r '
			["PRs abertas: " + (length | tostring)] +
			(map("#" + (.number | tostring) + " " + .title + " · " + .headRefName + " · " + (.author.login // "sem autor")) | .[:5]) |
			join("\n")
		' <<< "$prs"
	)"
fi

printf -v tooltip 'New-Omni · QA\n%s\nStatus: %s\nBranch: %s\nDisparado por: %s\n%s\n\n%s' \
	"$title" "$result" "$branch" "$user" "$created_local" "$pr_tooltip"

jq --compact-output --null-input \
	--arg text "QA $icon PR $pr_count" \
	--arg tooltip "$tooltip" \
	--arg class "$class" \
	'{text: $text, tooltip: $tooltip, class: $class}'
