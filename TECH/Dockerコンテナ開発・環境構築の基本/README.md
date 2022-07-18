# Dockerコンテナ開発・環境構築の基本

## COPY と ADDの違い

| 命令 | 動作                                                               |
| ---- | ------------------------------------------------------------------ |
| ADD  | リモートからもファイル追加できる。圧縮ファイルが自動解凍される     |
| COPY | リモートからのファイル追加は出来ない圧縮ファイルは自動解凍されない |

### COPYが望ましい

公式ドキュメントより

> Although ADD and COPY are functionally similar, generally speaking, COPY is preferred.  
> 引用: [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#add-or-copy)

理由

> - Imageサイズの観点
>   - レイヤー
> - セキュリティの観点
>   - リモート上のリソースを自動で取りに行くのでダウンロード中、中間者攻撃の対象となりえる
>   - 圧縮ファイルを自動で展開するので、ZIP爆弾やZIP SLIP脆弱性攻撃の対象となりえる  
>
> 引用: [DockerfileにてなぜADDよりCOPYが望ましいのか](https://qiita.com/momotaro98/items/bf34eef176cc2bdb6892)

## CMD と ENTRYPOINT の違い

| 命令 | 動作                                                               |
| ---- | ------------------------------------------------------------------ |
| CMD  | 実行プロセス、引数を上書きできる。変更可能性の高い可変部分に対して使う。     |
| ENTRYPOINT | 実行プロセス、引数を上書きできない。固定部分に対して使う。 |

```sh
docker container run <コンテナ名> <実行プロセス> <引数>
```

例：

```dockerfile
ENTRYPOINT ["ping","-c","1"]  # pingを1回実行（固定）
CMD ["localhost"] # localhostに対して（可変）
```

参考：[(Docker) CMDとENTRYPOINTの「役割」と「違い」を解説](https://hara-chan.com/it/infrastructure/docker-cmd-entrypoint-difference/)

## コンテナイメージの軽量化

メリット

- イメージのビルド時間が減る（ダウンロード時間が減る）
- イメージレジストリへのアップロード時間が減る
- イメージレジストリからのダウンロード時間が減る

### レイヤーを減らす

- まとめられるコマンドは `&&` で一度に実行する
- RUNが増えるとその１行がレイヤーになりコンテナイメージサイズが増えるので
- デメリットとして、可読性が落ちる
- イメージサイズとのトレードオフ

例：

```dockerfile:Dockerfile
FROM centos:7

# バラバラなのを…
# RUN yum -y install epel-release
# RUN yum -y install nginx

# ワンライナーに
RUN yum -y install epel-release && \
    yum -y install nginx
COPY index.html /usr/share/nginx/html
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
```

- Dockerfileのベストプラクティスは公式ドキュメントみるとよい [^1]
- ググってみるとコンテナイメージの軽量化を検証している記事がたくさんあるので参考に

[^1]: [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices)

### 軽量なベースイメージを使う

- 組み込み系システムで使われるBusyBox
- BusyBoxをベースに作られたAlpine Linux
- 余分なパッケージをなくした DebianのSlimイメージ
- distrolessがよく使われる。

### マルチステージビルド

- ビルド用と実行用でコンテナを分ける

```dockerfile:Dockerfile-msb
# stage 1
FROM golang:1.17 as builder

COPY ./main.go ./

RUN go build -o /msb ./main.go

# stage 2
FROM alpine:3.13

COPY --from=builder /msb /usr/local/bin/msb

ENTRYPOINT ["/usr/local/bin/msb"]
```

```golang:main.go
package main

import "fmt"

func main() {
    fmt.Println("Hello")
}
```

```sh
docker image build -t msb -f Dockerfile-msb .
docker container run -it --rm msb
Hello
```
