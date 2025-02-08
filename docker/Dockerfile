FROM ubuntu:25.04

ARG AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ARG AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ARG AWS_DEFAULT_REGION="ap-northeast-1"
ARG TENV_VERSION

ENV AWS_PROFILE=terraform

WORKDIR /usr/local/src

RUN apt-get update -y && \
    # curl, unzip, jq: インストールに必要, less: aws-cliコマンドで必要
    apt-get install -y curl unzip jq less git mandoc pre-commit && \
    # aws-cliインストール
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID} --profile ${AWS_PROFILE} && \
    aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY} --profile ${AWS_PROFILE} && \
    aws configure set region ${AWS_DEFAULT_REGION} --profile ${AWS_PROFILE} && \
    # SessionManager Plugin
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb && \
    # tenvインストール
    TAG_VERSION=${TENV_VERSION:-$(curl --silent https://api.github.com/repos/tofuutils/tenv/releases/latest | jq -r .tag_name)} && \
    curl -O -L "https://github.com/tofuutils/tenv/releases/download/${TAG_VERSION}/tenv_${TAG_VERSION}_amd64.deb" && \
    dpkg -i "tenv_${TAG_VERSION}_amd64.deb" && \
    # tflintインストール
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash && \
    # terraform各プロバイダのバイナリファイルキャッシュ設定・置き場の作成
    echo 'plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"' > $HOME/.terraformrc && \
    mkdir -p $HOME/.terraform.d/plugin-cache && \
    # インストール作業したディレクトリの削除
    rm -rf /usr/local/src/ && \
    # aptキャッシュ削除
    rm -rf /var/lib/apt/lists/

WORKDIR /iac

COPY .terraform-version .tflint.hcl .pre-commit-config.yaml ./

RUN tenv tf install && \
    tflint --init     
