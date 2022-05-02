require 'spec_helper'

RSpec.feature 'Search Feature' do

    def result_modal_visible
        wait_until { page.find('#results-count') }
	rescue => e
        flunk 'Expected modal to be visible.'
    end

	scenario 'load page with fields' do
		visit "/"
		expect(page).to have_text("Github Repo Search")
		expect(page).to have_button("Search")
		expect(page).to have_field("query")
	end

	scenario 'empty string input returns blank page' do
		visit "/"
		within("#search-container") do
			fill_in 'query', with: ''
		end
		click_button 'Search'
		sleep(5)
		expect(page).not_to have_content 'Results:'
	end

	scenario 'able to input search and get result headers' do
		visit "/"
		within("#search-container") do
			fill_in 'query', with: 'Rubocop'
		end
		click_button 'Search'
		sleep(5)
		expect(page).to have_content 'Results:'
		expect(page).to have_content 'Name'
		expect(page).to have_content 'Description'
		expect(page).to have_content 'License'
		expect(page).to have_content 'Visibility'
		within find('#table') do
			find_link('Rubocop', :visible => :all).visible?
		end
	end
end