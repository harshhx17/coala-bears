FROM circleci/jdk8:0.1.1

RUN echo "harsh"
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties curl
RUN add-apt-repository -y ppa:hvr/ghc
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN add-apt-repository -y ppa:avsm/ppa
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash  -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install -y python3.4-venv git bzip2 \
    cabal-install-1.24 clang-3.4 libreadline-dev libyaml-dev\
    gfortran ghc happy indent libblas-dev liblapack-dev \
    libperl-critic-perl libxml2-utils menhir php-codesniffer \
    build-essential ruby texinfo libbz2-dev libcurl4-openssl-dev \
    libexpat-dev libncurses-dev zlib1g-dev git-core libssl-dev \
    libsqlite3-dev sqlite3 libxslt1-dev libffi-dev yarn python3-dev \
    libgdbm-dev libncurses5-dev automake libtool bison

ENV HOME=/root
RUN   rm -rf /var/cache/apt/archives
RUN   ln -s $HOME/.apt-cache /var/cache/apt/archives
RUN   mkdir -p $HOME/.apt-cache/partial
RUN   mkdir -p $HOME/.RLibrary
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . $NVM_DIR/nvm.sh && nvm install 6.10.2
RUN . $NVM_DIR/nvm.sh && nvm alias default node

RUN . $NVM_DIR/nvm.sh
ENV CIRCLECI=true
ENV CIRCLE_JOB="python-3.5"
ENV PATH=/usr/lib/go-1.9/bin:$PATH
ENV PATH=/opt/cabal/bin:$PATH
ENV PATH=$HOME/coala-bears/node_modules/.bin:$PATH
ENV PATH=$HOME/coala-bears/vendor/bin:$PATH
ENV LINTR_COMMENT_BOT=false
ENV PATH=$HOME/dart-sdk/bin:$PATH
ENV PATH=$HOME/.cabal/bin:$PATH
ENV PATH=$HOME/infer-linux64-v0.7.0/infer/bin:$PATH
ENV PATH=$HOME/pmd-bin-5.4.1/bin:$PATH
ENV PATH=$HOME/bakalint-0.4.0:$PATH
ENV PATH=$HOME/elm-format-0.18:$PATH
ENV PATH=$HOME/.local/tailor/tailor-latest/bin:$PATH
ENV PATH=$HOME/phpmd:$PATH
ENV R_LIB_USER=$HOME/.RLibrary

ADD . /data

WORKDIR /data

RUN bash .ci/deps.apt.sh

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN bash ". /etc/profile.d/rvm.sh && rvm install 2.2.2 && rvm use 2.2.2 --default && ruby -v && gem install bundler && bash .ci/deps.sh"

RUN bash .ci/deps.cabal.sh

RUN git clone https://github.com/pyenv/pyenv.git /tmp/pyenv
RUN if [ ! -d "$HOME/.pyenv" ]; then mkdir -p ~/.pyenv ; fi
RUN cp -R /tmp/pyenv/* ~/.pyenv
ENV PYENV_ROOT=$HOME/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH
RUN eval "$(pyenv init -)"

RUN bash .ci/deps.pip.sh

RUN bash .ci/deps.java.sh

RUN bash .ci/deps.opam.sh

RUN bash .ci/deps.r.sh

RUN bash .ci/deps.coala-bears.sh

RUN codecov

RUN coala-ci -L DEBUG

RUN python setup.py bdist_wheel

RUN  pip install $(ls ./dist/*.whl)"[alldeps]"

RUN pip install -r docs-requirements.txt
RUN python setup.py docs

RUN bash .ci/tests.sh