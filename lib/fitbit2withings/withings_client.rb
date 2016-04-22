require "capybara"
require "capybara/poltergeist"

module Fitbit2withings
  class WithingsClient
    Capybara.javascript_driver = :poltergeist
    Capybara.ignore_hidden_elements = true
    Capybara.run_server = false
    Capybara.default_wait_time = 60

    def login
      session.visit "https://healthmate.withings.com/"
      session.fill_in :email, with: ENV["WITHINGS_EMAIL"]
      session.fill_in :password, with: ENV["WITHINGS_PASSWORD"]
      session.first('button[type="submit"]').click
    end

    def save(weight, fatmass)
      session.visit "https://healthmate.withings.com/"
      close_popup
      session.find("#addMeasurePopUpButton").click
      session.within("#addMeasureForm") do
        session.fill_in :Weight_kg, with: weight
        5.times do |_|
          break if session.has_selector?("#FatMassAddMeasurePercent")
          session.check "withFatMassAddMeasure"
          sleep 5
        end
        session.fill_in :FatMass_Percent, with: fatmass
      end
      session.find("#addMeasureSave").click
      sleep 15
    end

    def close_popup
      5.times do |_|
        break unless session.has_selector?("#hideCarrousselTuto")
        session.find("#hideCarrousselTuto").click
        sleep 5
      end
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end
  end
end
