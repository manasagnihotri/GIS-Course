# Guide: Hosting Lab Recordings on Google Drive

## Step 1: Upload Videos to Google Drive

1. **Create a folder** (optional but recommended):
   - Go to [Google Drive](https://drive.google.com)
   - Click "New" → "Folder"
   - Name it something like "QMSS 5070 Lab Recordings"

2. **Upload your video files**:
   - Open the folder you created
   - Click "New" → "File upload"
   - Select all your lab recording video files
   - Wait for uploads to complete

## Step 2: Get Shareable Links

For each video file:

1. **Right-click** on the video file in Google Drive
2. Click **"Share"** or **"Get link"**
3. Change the sharing settings:
   - Click "Change" next to "Restricted"
   - Select **"Anyone with the link"**
   - Make sure the permission is set to **"Viewer"** (not Editor)
   - Click "Done"
4. **Copy the link** - it will look like:
   ```
   https://drive.google.com/file/d/FILE_ID/view?usp=sharing
   ```

## Step 3: Convert to Direct Video Playback Links

Google Drive sharing links don't work directly for video playback in browsers. You need to convert them to a direct video link format.

### Method 1: Simple Conversion (Recommended)

Replace the link format:
- **Original**: `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`
- **Convert to**: `https://drive.google.com/uc?export=view&id=FILE_ID`

**How to get FILE_ID:**
- The FILE_ID is the long string between `/d/` and `/view` in your sharing link
- Example: If your link is `https://drive.google.com/file/d/1a2b3c4d5e6f7g8h9i0j/view?usp=sharing`
- Then FILE_ID is `1a2b3c4d5e6f7g8h9i0j`
- Your direct link becomes: `https://drive.google.com/uc?export=view&id=1a2b3c4d5e6f7g8h9i0j`

### Method 2: Using Google Drive Embed (Alternative)

For embedding videos directly in HTML:
```
https://drive.google.com/file/d/FILE_ID/preview
```

## Step 4: Update Your Website Links

Once you have the direct video links, update the links in `index.md`. 

**Current format:**
```markdown
[Lab 1: Choropleth Mapping](/lab-recordings/Lab%201%20Chloropeth%20Mapping.mp4)
```

**Replace with Google Drive link:**
```markdown
[Lab 1: Choropleth Mapping](https://drive.google.com/uc?export=view&id=YOUR_FILE_ID_HERE)
```

## Step 5: Test Your Links

1. Open your website locally or after deployment
2. Click on each lab recording link
3. Verify the video plays correctly

## Important Notes

⚠️ **File Size Limits:**
- Google Drive free accounts: 15 GB total storage
- Individual files can be up to 750 GB (for Google Workspace) or 5 TB (for personal accounts)
- Your lab recordings should fit within these limits

⚠️ **Bandwidth Considerations:**
- Google Drive has daily bandwidth limits for shared files
- If you expect high traffic, consider:
  - YouTube (unlimited bandwidth, better for many viewers)
  - Vimeo (professional option)
  - Your university's media server

⚠️ **Privacy:**
- Make sure sharing is set to "Anyone with the link" for public access
- Videos will be accessible to anyone who has the link
- Consider if you want to restrict access to students only

## Alternative: YouTube (Recommended for High Traffic)

If you expect many students to watch these videos:

1. Upload to YouTube (can be unlisted or public)
2. Get the YouTube video URL
3. Use the YouTube URL directly in your markdown:
   ```markdown
   [Lab 1: Choropleth Mapping](https://www.youtube.com/watch?v=VIDEO_ID)
   ```

YouTube handles bandwidth better and provides better video playback experience.

## Quick Reference: Link Format Examples

**Google Drive Direct Video:**
```markdown
[Lab 1: Choropleth Mapping](https://drive.google.com/uc?export=view&id=FILE_ID)
```

**Google Drive Preview (Embed):**
```markdown
[Lab 1: Choropleth Mapping](https://drive.google.com/file/d/FILE_ID/preview)
```

**YouTube:**
```markdown
[Lab 1: Choropleth Mapping](https://www.youtube.com/watch?v=VIDEO_ID)
```

## Need Help?

If you need help updating the links in your `index.md` file after you have the Google Drive links, just provide me with:
1. The video file name
2. The Google Drive sharing link (or FILE_ID)

And I can help update the website for you!
