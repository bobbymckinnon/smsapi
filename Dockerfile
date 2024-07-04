FROM perl
WORKDIR /opt/smsapi
COPY . .
#RUN cpan Mojolicious::Plugin::OpenAPI
#RUN cpan Mojolicious::Plugin::SwaggerUI
#RUN cpan OpenAPI::Client
#RUN cpanm YAML::XS

RUN cpanm --installdeps -n .
EXPOSE 3000
CMD ./script/smsapi prefork
