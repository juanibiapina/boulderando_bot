require "rails_helper"
require "telegram/bot/rspec/integration/rails"

RSpec.describe TelegramWebhooksController, type: :request, telegram_bot: :rails do
  describe "general error handling to prevent telegram from retrying requests" do
    context "when there's an error" do
      it "doesn't explode" do
        expect { dispatch_command(:delete_user_info) }.to_not raise_error
      end

      it "replies with the error message" do
        expect { dispatch_command(:delete_user_info) }.to make_telegram_request(bot, :sendMessage)
      end

      it "reports to Sentry" do
        allow(Sentry).to receive(:capture_exception)
        dispatch_command(:delete_user_info)
        expect(Sentry).to have_received(:capture_exception)
      end
    end
  end

  describe "commands" do
    describe "help" do
      it "replies with help text" do
        expect { dispatch_command(:help) }.to make_telegram_request(bot, :sendMessage)
      end
    end

    describe "privacy_policy" do
      it "replies with privacy policy text" do
        expect { dispatch_command(:privacy_policy) }.to make_telegram_request(bot, :sendMessage).with(hash_including(text: I18n.t("privacy_policy")))
      end
    end
  end
end
