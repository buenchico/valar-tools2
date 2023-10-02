# Assuming you are making this request in a method within a class (e.g., a controller or a service object)
module DiscourseApi
  class DiscourseGetData
    def self.get_users_data
      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'},
        url: 'https://www.valar.es'
        )

        users = [] # To store all the groups

        page = 0

      loop do
        response = connection.get('/directory_items.json', period: 'all', page: page)
        json_response = JSON.parse(response.body)

        # Append the current page's groups to the 'groups' array
        users.concat(json_response['directory_items'])

        # Check if there are more pages to fetch
        break if json_response["directory_items"].blank?

        # Move to the next page
        page += 1
      end

      return users
    end

    def self.get_groups_data

      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'},
        url: 'https://www.valar.es'
        )

      groups = [] # To store all the groups

      page = 0

      loop do
        response = connection.get('/groups.json', page: page)
        json_response = JSON.parse(response.body)
        puts page

        # Append the current page's groups to the 'groups' array
        groups.concat(json_response['groups'])

        # Check if there are more pages to fetch
        break if json_response["groups"].blank?

        # Move to the next page
        page += 1
      end

      return groups
    end
  end

  class DiscoursePostData
    def self.post_bug(message)
      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'application/json'},
        url: 'https://www.valar.es'
        )

        # Define the reply content as a JSON object
        reply_data = {

            "raw": message,
            "topic_id": 2983,
            "archetype": "regular",
            "reply_to_post_number": 0,
        }

        # Send the POST request to create the reply
        response = connection.post("/posts.json", reply_data.to_json)

        # Check the response
        if response.success?
          # The reply was created successfully
          puts 'Reply created successfully!'
        else
          # Handle the error
          puts "Error creating reply: #{response.status}: #{response.body}"
        end
    end
  end
end
