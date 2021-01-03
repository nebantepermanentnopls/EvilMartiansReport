ARG RUBY_VERSION
ARG NODE_VERSION

FROM ruby:${RUBY_VERSION}

WORKDIR /app

# переносим в начало установку необходимых пакетов, чтобы происходиле кеширование 
# и слой не пересобирался при изменении файлов в дирректории проекта и тд
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \		
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && \
	  apt-get -yq install libpq-dev nodejs yarn

COPY Gemfile Gemfile.lock /app/		    # выносим отдельно установку 
RUN bundle install			              # гемов для кеширования(более быстрой установки)

COPY package.json yarn.lock /app/	    # выносим отдельно установку 
RUN yarn install --check-files		    # yarn пакетов для кеширования(более быстрой установки)

COPY . /app/

RUN yarn build
RUN rails assets:precompile
