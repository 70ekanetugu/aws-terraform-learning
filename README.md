# About
Dockerコンテナ上でterraformを動かすためのプロジェクト。

## Tools
主な使用ツールは以下の通り。  
いずれもDockerfileに含めているためインストール作業は不要。

ツール | 用途 
:--|:--
aws cli | AWS操作用
tenv | terraformのバージョン管理ツール
terraform | IaCツール
tflint | terraform用のLinter

# Setup
1. AWS側でterraform用のIAMユーザーを作成する
    - 作成時、IAMポリシーとして `AdministratorAccess` を付与しておく
1. IAMユーザー作成後、アクセスキーを発行しcsv DLしメモっておく
1. docker/.envファイルを作成し以下をセットする
    - 必須
      - AWS_ACCESS_KEY_ID=<発行したアクセスキーのキー>
      - AWS_SECRET_ACCESS_KEY=<発行したアクセスキーの値>
    - 任意
      - AWS_DEFAULT_REGION=<リソース作成対象のリージョン名>
1. VSCode, cursor等の場合、以下拡張機能をdevcontainer.jsonに追加することを推奨
    - HashiCorp.terraform
    - AmazonWebServices.aws-toolkit-vscode
1. VSCode, cursor等でdev containerを起動する
1. コンテナ上で以下確認を行う
    ```shell
    # aws-cliの確認
    aws --version

    # アカウントIDが表示されることを確認(「The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.」が表示される)
    aws sts get-caller-identity --query Account --output text

    # SessionManager Pluginの確認
    session-manager-plugin

    # tenvの確認
    tenv --version

    # tflintの確認
    tflint --version

    # terraformの確認
    terraform version
    ```
1. 必要なバイナリのインストールを行う。
    ```shell
    terraform init
    ```
1. pre-commitの初期化
    ```shell
    pre-commit install

    # 手動チェック：全部Passedになることを確認
    pre-commit run -a
    ```

# 基本的な使い方
## フォーマット
```shell
terraform fmt --recursive
```
`*.tf` ファイルの自動フォーマットを行う。  
`--recursive` をつけない場合、カレントディレクトリのファイルのみが対象になる。

## バリデーション
```shell
terraform validate
```
terraformファイルのバリデーションを行う。  
構文レベルのチェックのみのため、より詳細なチェックは後述 tflint を使う。

## Linterの実行
```shell
tflint
```
Linterで `*.tf` ファイルのチェックを実行する。  
`.tflint.hcl` ファイルの設定を参照。

## 実行計画
```shell
terraform plan
```
実行計画を表示する。 `*.tf` を実行した時に何が起こるかを表示してくれる。  
大まかなアイコンは以下の通り。
- `+` ： リソースの作成
- `-` ： リソースの削除
- `-/+` ： リソースを削除して作成し直す

## 実行
```shell
terraform apply [-var-file="terraform.tfvarsのパス"]
```
実際にaws上に適用するためのコマンド。
`*.tf` の内容を変更して、AWSリソースの設定を更新する場合もこのコマンドを使う。
このコマンドを実行すると実際にAWS上にリソースが作成・更新・削除されるため注意。

オプションの-var-fileで入力を渡すこともできる。  
なお、ルートのterraform.tfvarsは無条件で読み込まれるため指定は不要。
environments/dev/terraform.tfvarsのように環境に応じた入力を用意する場合などで使用することが多い。

## リソース削除
```shell
terraform destroy
```
AWSリソースを削除するためのコマンド。  
ALBなど削除保護設定がされているリソースがあると失敗する。

# ファイル構成



# 参考資料
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- https://www.amazon.co.jp/%E5%AE%9F%E8%B7%B5Terraform-AWS%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0%E8%A8%AD%E8%A8%88%E3%81%A8%E3%83%99%E3%82%B9%E3%83%88%E3%83%97%E3%83%A9%E3%82%AF%E3%83%86%E3%82%A3%E3%82%B9-%E6%8A%80%E8%A1%93%E3%81%AE%E6%B3%89%E3%82%B7%E3%83%AA%E3%83%BC%E3%82%BA%EF%BC%88NextPublishing%EF%BC%89-%E9%87%8E%E6%9D%91-%E5%8F%8B%E8%A6%8F/dp/4844378139
- https://zenn.dev/yuma_ito_bd/scraps/fbef03191b90d1
- https://developer.hashicorp.com/terraform/language/style (スタイルガイド)
