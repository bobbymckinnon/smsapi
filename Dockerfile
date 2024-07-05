FROM perl
WORKDIR /opt/smsapi
COPY . .
RUN cpanm -n Mojolicious::Plugin::OpenAPI
RUN cpanm -n Mojolicious::Plugin::SwaggerUI
RUN cpanm -n OpenAPI::Client
RUN cpanm -n YAML::XS

RUN cpanm --installdeps -n .
EXPOSE 3000
CMD ./script/smsapi prefork
