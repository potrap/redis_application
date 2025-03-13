defmodule RedisApplication.Mailer do
  use Swoosh.Mailer, otp_app: :redis_application
end
