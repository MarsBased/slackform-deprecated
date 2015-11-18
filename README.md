# Slackform

Slackform is a command line tool to automatically invite new members to a Slack team from the answers of a Typeform.

When you run it, it sends an invitation for each new answer on the Typeform, using the data given on that answer (first name, last name and email).

It is intended to be run periodically (for instance, every 5 minutes) using a process scheduler such as cron, and it will only invite members "registered" since the last run.

## How it works

Each time the tool is run, it performs the following process:

1. It checks if there is an existing file with the timestamp of the last invitation sent.
2. It gets the form answers:
	- If it finds the file, it reads it and gets the Typeform answers submitted **since** that timestamp.
	- If it does not find the file, it gets **all** Typeform answers submitted.
3. For each answer, it creates a new Slack invitation.
4. It overwrites the timestamp file with the timestamp of the last answer submitted.

This allows the tool to be run periodically and only invite new members on each run, so that invitations are only sent once for each new member.

**WARNING:** When you first run the tool, if you don't specify a last timestamp file, or it is empty, it will send invitations for **ALL** the answers on the Typeform, since the beginning of times. If you have already invited some members manually you just need to create a file with the timestamp of the last time you sent the invitations.

For example, if you last sent invitations on the 18th of November of 2015 at 10am (moreless), create a file with the following contents:

```
1447840800
```

Then you will need to pass the path of this file as an argument when running the tool (see [Running](#running)).

**NOTE:** The timestamp stored on the timestamp file is an Epoch timestamp, you can use [an Epoch converter](http://www.epochconverter.com/) to convert a date to a timestamp.

## Installation

### Dependencies

The following is needed to run the tool:

* Ruby >= 1.9.3
* Git (needed to clone the repo in order to install the gem)

### How to install

Follow these steps to install:

1. Clone this repository: ```git clone https://github.com/MarsBased/slackform```
2. Install the gem you will find in the directory: ```gem install slackform/slackform-[VERSION].gem```

## Running

Slackform includes the executable ```slackform``` which can be used to execute the invitation process. It also includes a command to list all the Slack team channels along with their ids, this is useful to configure the channels where you want to invite new members (see [Configuration](#configuration)).

For both commands, you need to provide the path to a configuration file. The configuration file is a YAML file with all the parameters required to access both the Slack and Typeform APIs and to run the invitation process. See [Configuration](#configuration) for details about the configuration parameters.

Additionally, for the invite command you can optionally pass a ```--last-timestamp-file PATH_TO_LAST_TIMESTAMP_FILE``` option to specify the file where the last timestamp is stored. Answers submitted prior to that date will not be read.

To run the invitation process execute the following command:

```
slackform invite -c PATH_TO_YOUR_CONFIGURATION_FILE [--last-timestamp-file PATH_TO_LAST_TIMESTAMP_FILE]
```

To list all the channels with their id execute the following command:

```
slackform list_slack_channels -c PATH_TO_YOUR_CONFIGURATION_FILE
```

### Running automatically

Usually you will need to run the invite command periodically every X minutes, so that all new invitations are sent. You can use a task scheduler such as cron (on Unix) for that.

If you want to use cron to run the process every 5 minutes, you can create a cron job like the following:

```
*/5 * * * * slackform invite -c ABSOLUTE_PATH_TO_YOUR_CONFIGURATION_FILE [--last-timestamp-file PATH_TO_LAST_TIMESTAMP_FILE]
```

Depending on your setup, you may need to specify the full path to the slackform binary instead of just ```slackform``

You can also run it as a new bash session so that it uses your user's environment, otherwise it will use cron's environment and may not work.
```
*/5 * * * * [your_user] /bin/bash -l -c 'slackform invite -c ABSOLUTE_PATH_TO_YOUR_CONFIGURATION_FILE [--last-timestamp-file PATH_TO_LAST_TIMESTAMP_FILE]'
```



## Configuration

In order to configure Slackform, you need to create a slackform.yml file following the example structure (slackform.example.yml), and fill it with your Typeform and Slack specific information.

- **typeform_api_key:** You can find it in your Typeform user area, in the "My Account" page (top right).
- **typeform_uid:** This is the identifier of the form from which you want to get the answers. It's the last part of the form URL. For example if the form URL is: ```https://cooluser.typeform.com/to/i8Xh28``` then the UID is ```18Xh28```
- **slack_api_key:** You can find it in the Slack API page while you are logged in your Slack team. Go to the [Slack Web API page](https://api.slack.com/web) and in the "Authentication" section you will be able to see or create the token for the team. Note that in this page you will see the API tokens for all the Slack teams where you are registered. Just copy the token of the team where you want to invite the new members.
- **slack_team:** This is the name of the Slack team where you want to invite new members. This is just yours Slack subdomain. For example, if you access Slack through ```https://coolteam.slack.com```, then the Slack team is ```coolteam```
- **slack_channels (OPTIONAL):** When you invite a new member to your Slack team, you can specify the channels where it will be invited. With this option you can specify an array (in YAML) with the identifiers of the channels where you want to invite new members. If you leave it blank it will use the default behaviour (invite to the #general channel). You can use the ```list_slack_channels``` command to see the identifiers of all channels.
- **typeform_field_ids:** An Slack invitation consists of 3 parameters: an email (required), a first name (optional) and a last name (optional). This option is used to specify the Typeform fields that are used to extract each of the parameters. For each invitation parameter you need to specify the Typeform field id that will be used. See [how to check a typeform field id](#how-to-check-a-typeform-field-id) for details.

### How to check a Typeform field ID

Follow these steps:

1. Open the Form edition page
![image](https://cloud.githubusercontent.com/assets/3403704/11236413/bb45c554-8dd9-11e5-8f03-9f3dbb611d30.png)

2. Check the HTML of the field. In Chrome and other browsers you can just "Inspect Element" on the field.
![image](https://cloud.githubusercontent.com/assets/3403704/11236582/f57f2340-8dda-11e5-8d56-65b039952910.png)

3. Find the parent ```<li>``` element for the field and check its ```id``` attribute, it should be something like: ```field-12345678```
![image](https://cloud.githubusercontent.com/assets/3403704/11236716/b2af6c68-8ddb-11e5-9e50-5782336e8cce.png)

4. Finally replace the "field-" part by "textfield_" and that's your id. For example, for "field-12345678" it would be "textfield_12345678".

**NOTE:** This is assuming you are using textfields in your form, if you use other type of fields (like text areas), then replace the "textfield" part by "textarea" or whatever type of field.

### Optional Slack notifications

Optionally, you can have Slackform notify you to a Slack channel about sucessful and failed invitations. Each time it tries to invite someone (because there is a new answer in the Typeform) it will either send a "success" message or an "error" message to the Slack channel.

You can configure it to send a message to any Slack channel of any team (not necessarily the same team you are integrating Typeform with).

To configure notifications, add the following options to the YAML configuration file:

- **enable_slack_notifications:** Set it to ```true```
- **slack_notifications_webhook:** a Slack "Incoming Webhook", which is like a regular URL, and tells Slack where to post the messages.

Follow these steps to configure a new Webhook:

1. Open the Slack administration panel for the team where you want notifications to be posted. For example: ```https://coolteam.slack.com/admin```
2. In the side menu go to "Integrations"
3. Click "View" on "Incoming WebHooks"

Now you need to configure the integration:

4. Select the channel where you want notifications to be posted
5. Click on "Add Incoming WebHooks integration"
6. Copy the "Webhook URL". This is the URL you need to use in the YAML configuration.
7. In "Integration Settings", configure the details of the integration as you wish, the different settings are self-explanatory.

## TODO

- Add optional logging into a file
- Add tests

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MarsBased/slackform.
