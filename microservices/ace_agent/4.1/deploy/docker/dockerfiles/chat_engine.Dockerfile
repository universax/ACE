ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG HOST_UID
ARG HOST_GID

RUN echo "Creating docker image for Chat Engine.."

# 最初にホームディレクトリを作成します
# これにより、所有権を設定したり使用したりする前にディレクトリが存在することを確認します。
RUN mkdir -p /home/ace-agent

# 既存のUID/GIDを処理しつつ、ユーザーとグループを堅牢に作成します
# このセクションでは、作成を試みる前にグループとユーザーが既に存在するかどうかを確認します。
# HOST_UIDとHOST_GIDを持つユーザーがエラーなしで存在することを保証することを目指します。
RUN \
  # ターゲットGIDが存在するかどうかを確認します
  if ! getent group $HOST_GID > /dev/null 2>&1; then \
    # GIDが存在しない場合、HOST_GIDでグループ 'ace-agent' を作成します
    echo "---> GID $HOST_GID のグループは存在しません。GID $HOST_GID でグループ 'ace-agent' を作成します..." ; \
    groupadd -g $HOST_GID ace-agent ; \
  else \
    # GIDが存在する場合、メッセージを表示します。既存のグループを使用します。
    echo "---> GID $HOST_GID のグループは既に存在します。既存のグループを使用します。" ; \
    # オプション: 必要であれば、ここで既存のグループ名を取得できます:
    # EXISTING_GROUP_NAME=$(getent group $HOST_GID | cut -d: -f1)
    # echo "---> GID $HOST_GID の既存のグループ名は '$EXISTING_GROUP_NAME' です。"
  fi && \
  # ターゲットUIDが存在するかどうかを確認します
  if ! getent passwd $HOST_UID > /dev/null 2>&1; then \
    # UIDが存在しない場合、HOST_UIDでユーザー 'ace-agent' を作成し、HOST_GIDグループに割り当てます
    echo "---> UID $HOST_UID のユーザーは存在しません。UID $HOST_UID と GID $HOST_GID でユーザー 'ace-agent' を作成します..." ; \
    useradd --shell /bin/bash --uid $HOST_UID --gid $HOST_GID --no-create-home --home-dir /home/ace-agent ace-agent ; \
  else \
    # UIDが存在する場合、メッセージを表示します。ユーザーがHOST_GIDグループに関連付けられていることを確認します。
    echo "---> UID $HOST_UID のユーザーは既に存在します。ユーザーがグループGID $HOST_GID の一部であることを確認します。" ; \
    # 既存のUIDに対応するユーザー名を取得します
    EXISTING_USER_NAME=$(getent passwd $HOST_UID | cut -d: -f1) ; \
    echo "---> UID $HOST_UID の既存のユーザー名は '$EXISTING_USER_NAME' です。" ; \
    # この既存ユーザーがターゲットグループGID $HOST_GID の一部であることを確認します
    # これは、ユーザーが存在するが異なるプライマリグループに属している場合に必要になることがあります。
    usermod -a -G $HOST_GID $EXISTING_USER_NAME ; \
    # 可能であればプライマリグループも正しく設定されていることを確認します（ユーザーがログインしている場合は失敗する可能性があり、通常はそれほど重要ではありません）
    usermod -g $HOST_GID $EXISTING_USER_NAME || echo "プライマリグループを設定できませんでした（問題ないかもしれません）。" ; \
  fi && \
  # 常にホームディレクトリの所有権が正しいことを確認します
  echo "---> UID $HOST_UID GID $HOST_GID のための /home/ace-agent の所有権を確認しています..." && \
  chown -R $HOST_UID:$HOST_GID /home/ace-agent

##############################
# カスタム依存関係のインストール
##############################
# もしあれば、ここに依存関係のインストール手順を追加します

WORKDIR /home/ace-agent

# 後続のRUNコマンドおよびコンテナのデフォルトユーザーとしてユーザーを設定します
# 注意: docker-compose.yml 内の 'user:' ディレクティブは、最終的に実行されるコンテナプロセスに対してこれを上書きします。
USER $HOST_UID:$HOST_GID

# 元のCMDまたはENTRYPOINTはここに記述します
# 例: CMD ["aceagent", "chat", "server", ...]
