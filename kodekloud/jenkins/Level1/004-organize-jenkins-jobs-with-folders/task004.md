# Task 004 - Organize Jenkins Jobs with Folders

xFusionCorp Industries' DevOps team aims to streamline the management of Jenkins jobs by organizing them into distinct folders based on their purpose. Complete the task following the provided requirements:

1.Access the Jenkins UI by clicking on the Jenkins button in the top bar. Log in using the credentials: username `admin` and password `Adm!n321`.

2. Create a new folder named `Apache` within the Jenkins UI.

3. Move the existing jobs `httpd-php` and `services` under the newly created `Apache` folder.

Note:

1. Ensure to install any required plugins and restart the Jenkins service if necessary. Opt for Restart Jenkins when installation is complete and no jobs are running on the plugin installation/update page.

2. Be aware that Jenkins UI may experience temporary unresponsiveness during the service restart. Refresh the UI page if needed.

3. Capture screenshots of your work for documentation and review purposes. Alternatively, utilize screen recording software like loom.com for detailed documentation and sharing.

## Solution Steps:

1. Log in to the Jenkins UI using the provided credentials.
2. Navigate to "Manage Jenkins" > "Manage Plugins".
3. Install the "Folders" plugin if it is not already installed. After installation, choose "Restart Jenkins when installation is complete and no jobs are running".
4. Once Jenkins has restarted, refresh the UI page if necessary.
5. From the Jenkins dashboard, click on "New Item".
6. Enter the name `Apache` for the new folder and select "Folder" as the item type. Click "OK" to create the folder.
7. Go back to the Jenkins dashboard and locate the jobs `httpd-php` and `services`.
8. For each job, click on the job name, then select "Move" from the left-hand menu.
9. Choose the `Apache` folder as the destination and confirm the move.
10. Verify that both jobs are now located within the `Apache` folder.
