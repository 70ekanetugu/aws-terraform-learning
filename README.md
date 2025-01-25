# Setup
1. AWS側でterraform用のIAMユーザーを作成する
    - 作成時、IAMポリシーとしてAdminAccessを付与しておく
2. IAMユーザー作成後、アクセスキーを発行しcsv DLしメモっておく
3. docker/.envファイルを作成し以下をセットする
    - AWS_ACCESS_KEY_ID=<発行したアクセスキーのキー> (必須)
    - AWS_SECRET_ACCESS_KEY=<発行したアクセスキーの値> (必須)
    - AWS_DEFAULT_REGION=<リソース作成対象のリージョン名> (任意)
4. VSCode, cursor等の場合以下拡張機能をdevcontainer.jsonに追加しておく
    - HashiCorp.terraform
    - AmazonWebServices.aws-toolkit-vscode
5. VSCode, cursor等でdev containerを起動する
6. コンテナ上で以下確認を行う
    ```shell
    # aws-cliの確認
    aws --version

    # アカウントIDが表示されることを確認
    aws sts get-caller-identity --query Account --output text

    # tenvの確認
    tenv --version

    # terraformの確認
    terraform version
    ```

# 初期化


# 参考資料
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- https://zenn.dev/yuma_ito_bd/scraps/fbef03191b90d1
