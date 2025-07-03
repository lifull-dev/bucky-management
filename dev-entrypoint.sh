#!/bin/bash
set -e

# SECRET_KEY_BASEが設定されていない場合は生成
if [ -z "$SECRET_KEY_BASE" ]; then
  echo "Generating SECRET_KEY_BASE for development..."
  export SECRET_KEY_BASE=$(bundle exec rails secret)
  echo "SECRET_KEY_BASE generated successfully"
fi

# 引数で渡されたコマンドを実行
exec "$@"
