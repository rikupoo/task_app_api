#Dockerでは最初にベースイメージ（土台）を指定する
#FROM ベースイメージ:タグ
#alpine(ディストリビュージョン)じょうで作られたrubyを指定
FROM ruby:2.7.2-alpine

#ARGはDockerfile内の変数宣言
ARG WORKDIR

#ENVは環境変数定義(Dockerfile,コンテナで参照可)
ENV RUNTIME_PACKAGES="linux-headers libxml2-dev make gcc libc-dev nodejs tzdata postgresql-dev postgresql git" \
    DEV_PACKAGES="build-base curl-dev" \
    HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# RUNはベースイメージに対してコマンドを実行する
#作業ディレクトリを定義
RUN echo ${HOME}

#WORKDIRはDockerfile内で指定した命令を実行する...RUN,COPY,ADD,ENTORYPOINT,CMD
WORKDIR ${HOME}

#COPYはホスト側(自PC)のファイルをコンテナにコピー
#COPY コピー元(ホスト) コピー先(コンテナ)
#コピー元はDockerfileがあるディレクトリ以下を指定する必要がある(api)
#Gemfile*...Gemfileから始まる全てを指定(今回はGemfile,Gemfile.look)
COPY Gemfile* ./

#apk ... alpine linuxのコマンド
#apk update = パッケージの最新リストを取得
RUN apk update && \
    #apk upgrade = インストールパッケージを最新のものに
    apk upgrade && \
    #apk add = パッケージのインストールを実行
    #--no-cache = パッケージをキャッシュしない(Dockerイメージの軽量化)
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    #--virtual 名前(任意) = 仮想パッケージ
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    #bundle install = Gemのインストールコマンド
    #-j4(jobs=4) = Gemインストールの高速化
    bundle install -j4 && \
    #パッケージを削除(bundle install後以下のパッケージは必要なくなる為に削除、Dockerイメージの軽量化)
    apk del build-dependencies

#  . はDockerfileがあるディレクトリの全てのファイル(サブディレクトリ含む)
COPY . ./

#コンテナ内で実行したいコマンドを定義
#-b ... バインド。プロセスを指定したIP(0.0.0.0)に紐付け(バインド)する
#CMD ["rails", "server", "-b", "0.0.0.0"]

#ホスト(PC)     : コンテナ
#ブラウザ(外部)  : Rails
#コンテナからすればPCのブラウザは外部のブラウザ、railsサーバーで起動したプロセスは外部ブラウザから参照できない
#そこでIPを0.0.0.0にバインドすることによりコンテナのrailsを外部から参照可能にする