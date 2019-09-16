FROM alpine

ENV TERM=xterm-256color
ENV PATH="/diff-so-fancy:$PATH"
RUN apk update && apk add perl git ncurses
COPY . /diff-so-fancy

ENTRYPOINT ["diff-so-fancy"]
