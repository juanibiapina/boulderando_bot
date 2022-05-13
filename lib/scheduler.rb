# frozen_string_literal: true

require 'capybara'
require 'capybara/dsl'
require 'chronic'

class Scheduler
  include Capybara::DSL

  class SafetyCheckError < StandardError; end

  def schedule_basement(user, day, month, time, submit: false)
    # select URL
    Capybara.app_host = 'https://basement-boulderstudio.de/'

    # visit website
    visit('/booking')

    # select regular slots (after 14 or weekends)
    find('.drp-course-list-item-regulaere-slots').click

    # advance month if needed
    month_diff = month - Date.today.month
    month_diff.times do
      find('.drp-course-month-selector-next').click
    end

    # click day
    find('.drp-calendar-day.drp-calendar-day-dates', text: day).click # only if the correct month is already selected

    # click book button on chosen time
    find('.drp-course-date-item', text: time).find_button(text: 'Buchen').click

    # fill in user data
    fill_in('Vorname*', with: user.name)
    fill_in('Nachname*', with: user.last_name)
    fill_in('Email*', with: user.email)
    select('Urban Sports Club')
    fill_in('Mitgliedsnummer USC*', with: user.usc_number)

    # click submit button
    find('.drp-course-booking-continue').click

    # accept data protection terms
    find('label.drp-d-block').click

    # run safety check
    text = find('.drp-course-date-item-date').text
    m = /[^,]*, (..\...\...) (.*)/.match(text) # "Di., 01.02.22 18:30 - 20:30"
    scheduled_time = m[2]
    if scheduled_time != time
      raise SafetyCheckError, "would schedule wrong time: #{scheduled_time}"
    end

    # submit form
    if submit
      find('button.drp-booking-overview-booking-btn').click
    end

    {
      scheduled_time: scheduled_time,
    }
  end

  def schedule_boulderklub(user, day, month, time, submit: false)
    # select URL
    Capybara.app_host = 'https://boulderklub.de'

    # visit website
    visit('/en/booking/adult-slots/')

    # advance month if needed
    month_diff = month - Date.today.month
    month_diff.times do
      find('.drp-course-month-selector-next').click
    end

    # click day
    find('.drp-calendar-day', text: /\A#{day}\z/).click # only works if the correct month is already selected

    # click book button on chosen time
    find('.drp-course-date-item', text: time).find_button(text: 'BUCHEN').click

    # fill in user data
    fill_in('Vorname*', with: user.name)
    fill_in('Nachname*', with: user.last_name)
    fill_in('Geburtsdatum* (TT.MM.JJJJ)', with: user.birthday.strftime('%d.%m.%Y'))
    fill_in('Mobilnummer*', with: user.phone_number)
    fill_in('Email*', with: user.email)
    select('Urban Sports Club')
    fill_in('Mietgliedsnummer USC*', with: user.usc_number)

    # click submit button
    find('.drp-course-booking-continue').click

    # accept data protection terms
    find('label.drp-d-block').click

    # run safety check
    text = find('.drp-course-date-item-date').text
    m = /[^,]*, (..\...\...) (.*)/.match(text) # "Di., 01.02.22 18:30 - 20:30"
    scheduled_time = m[2]
    if scheduled_time != time
      raise SafetyCheckError, "would schedule wrong time: #{scheduled_time}"
    end

    # submit form
    if submit
      find('button.drp-booking-overview-booking-btn').click
    end

    {
      scheduled_time: scheduled_time,
    }
  end
end
