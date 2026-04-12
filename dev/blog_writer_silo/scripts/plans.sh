#!/bin/bash
# plans.sh — Manage blog post plans
# Usage: ./plans.sh [CMD] [ARGS]

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLANS_DIR="$SILO_DIR/plans"

CMD="${1:-list}"

case "$CMD" in
    list|ls)
        echo "=== Blog Post Plans ==="
        echo ""
        count=0
        for f in "$PLANS_DIR"/*.json; do
            [ -f "$f" ] || continue
            count=$((count + 1))
            name=$(basename "$f" .json)
            status=$(jq -r '.status' "$f")
            title=$(jq -r '.title' "$f")
            echo "[$status] $name"
            echo "  $title"
            echo ""
        done
        [ $count -eq 0 ] && echo "(no plans)" || true
        ;;
    
    show|view)
        NAME="${2:-}"
        if [ -z "$NAME" ]; then
            echo "Usage: ./plans.sh show PLAN_NAME"
            echo "Available:"
            ls "$PLANS_DIR"/*.json 2>/dev/null | xargs -I{} basename {} .json
            exit 1
        fi
        
        # Find plan by partial name
        PLAN_FOUND=""
        for f in "$PLANS_DIR"/*.json; do
            if [[ "$f" == *"$NAME"* ]]; then
                PLAN_FOUND="$f"
                break
            fi
        done
        
        if [ -z "$PLAN_FOUND" ]; then
            echo "Plan not found: $NAME"
            echo "Available:"
            ls "$PLANS_DIR"/*.json 2>/dev/null | xargs -I{} basename {} .json
            exit 1
        fi
        
        jq '.' "$PLAN_FOUND"
        ;;
    
    create|new)
        NAME="${2:-}"
        TITLE="${3:-}"
        TOPIC="${4:-}"
        if [ -z "$NAME" ] || [ -z "$TITLE" ]; then
            echo "Usage: ./plans.sh create NAME TITLE [TOPIC]"
            exit 1
        fi
        # Add .json if not present
        [[ "$NAME" != *.json ]] && NAME="${NAME}.json"
        
        if [ -f "$PLANS_DIR/$NAME" ]; then
            echo "Plan already exists: $NAME"
            exit 1
        fi
        
        jq -n \
            --arg name "$NAME" \
            --arg title "$TITLE" \
            --arg topic "${TOPIC:-$NAME}" \
            --arg created "$(date +%Y-%m-%d)" \
            '{
                title: $title,
                topic: $topic,
                status: "planned",
                created: $created,
                updated: $created,
                tags: [],
                sections: [],
                stories: [],
                notes: "",
                draft: null,
                post: null
            }' > "$PLANS_DIR/$NAME"
        
        echo "Created: $PLANS_DIR/$NAME"
        ;;
    
    update|set)
        NAME="${2:-}"
        KEY="${3:-}"
        VALUE="${4:-}"
        if [ -z "$NAME" ] || [ -z "$KEY" ]; then
            echo "Usage: ./plans.sh update NAME KEY VALUE"
            exit 1
        fi
        [[ "$NAME" != *.json ]] && NAME="${NAME}.json"
        
        if [ ! -f "$PLANS_DIR/$NAME" ]; then
            echo "Plan not found: $NAME"
            exit 1
        fi
        
        # Update the key and updated timestamp
        tmpfile=$(mktemp)
        jq --arg key "$KEY" --arg value "$VALUE" --arg updated "$(date +%Y-%m-%d)" \
            '.[$key] = $value | .updated = $updated' \
            "$PLANS_DIR/$NAME" > "$tmpfile"
        mv "$tmpfile" "$PLANS_DIR/$NAME"
        
        echo "Updated $KEY = $VALUE"
        ;;
    
    status)
        NAME="${2:-}"
        STATUS="${3:-}"
        if [ -z "$NAME" ] || [ -z "$STATUS" ]; then
            echo "Usage: ./plans.sh status NAME STATUS"
            exit 1
        fi
        [[ "$NAME" != *.json ]] && NAME="${NAME}.json"
        
        if [ ! -f "$PLANS_DIR/$NAME" ]; then
            echo "Plan not found: $NAME"
            exit 1
        fi
        
        tmpfile=$(mktemp)
        jq --arg status "$STATUS" --arg updated "$(date +%Y-%m-%d)" \
            '.status = $status | .updated = $updated' \
            "$PLANS_DIR/$NAME" > "$tmpfile"
        mv "$tmpfile" "$PLANS_DIR/$NAME"
        
        echo "Status: $STATUS"
        ;;
    
    delete|rm)
        NAME="${2:-}"
        if [ -z "$NAME" ]; then
            echo "Usage: ./plans.sh delete NAME"
            exit 1
        fi
        [[ "$NAME" != *.json ]] && NAME="${NAME}.json"
        
        if [ ! -f "$PLANS_DIR/$NAME" ]; then
            echo "Plan not found: $NAME"
            exit 1
        fi
        
        rm -i "$PLANS_DIR/$NAME"
        echo "Deleted: $NAME"
        ;;
    
    help|--help|-h)
        echo "Usage: ./plans.sh [command] [args]"
        echo ""
        echo "Commands:"
        echo "  list                 List all plans"
        echo "  show NAME            Show plan details"
        echo "  create NAME TITLE   Create new plan"
        echo "  update NAME KEY VAL Update plan field"
        echo "  status NAME STATUS  Set plan status"
        echo "  delete NAME         Delete plan"
        echo ""
        echo "Status values: planned, drafting, draft, review, published"
        ;;
    
    *)
        echo "Unknown command: $CMD"
        echo "Run './plans.sh help' for usage"
        exit 1
        ;;
esac
