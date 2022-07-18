FROM node:17-alpine3.14

WORKDIR /md

RUN apk update && \
    apk add git

RUN git clone https://github.com/xt0rted/markdownlint-problem-matcher.git && \
    cd markdownlint-problem-matcher && \
    npm install -g npm && \
    npm install -g markdownlint-cli

ENTRYPOINT ["markdownlint"]
CMD ["**/*.md", "--ignore", "node_modules", "-c", ".markdownlint.yaml"]
