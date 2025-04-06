#!/bin/bash
#
# 踏み台サーバ用のセットアップスクリプト
#

sudo dnf update -y

# RDS for PostgreSQL 15用
sudo dnf install -y postgresql15

# Aurora for MySQL(8.0)用
sudo dnf install -y mariadb105 

# =========================================================
# その他調査用： 必要に応じてインストールすること。
# =========================================================
#
# AWSリソースのアクセス確認に使用。接続先のリソースにアクセスできない場合、SGやネットワークACL、RTBを見直すこと。
# ex). $ telnet <IP|DNS> <PORT>
# dnf install -y telnet
