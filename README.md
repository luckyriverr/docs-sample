# docs-sample

## ドキュメント形式

フリー（markdown推奨）

## 前提

Docker インストール
<https://docs.docker.com/engine/install/>

## 書式チェック

- 以下コマンドを実行

  ```sh
  docker image build -t markdownlint .
  docker container run -v $PWD:/md -it --rm markdownlint
  ```

- 書式エラーがあると…

  ```sh
  README.md:280 MD032/blanks-around-lists Lists should be surrounded by blank lines [Context: "..."]
  ```

  cf. [書式ルール一覧](https://github.com/DavidAnson/markdownlint#rules--aliases)
