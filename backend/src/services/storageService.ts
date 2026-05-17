import admin from 'firebase-admin';
import { v4 as uuidv4 } from 'uuid';

export const uploadImage = async (fileBuffer: Buffer, mimetype: string): Promise<string> => {
  // Make sure FIREBASE_STORAGE_BUCKET is in your .env
  const bucket = admin.storage().bucket(process.env.FIREBASE_STORAGE_BUCKET); 
  const filename = `receipts/${uuidv4()}-${Date.now()}`;
  const file = bucket.file(filename);

  await file.save(fileBuffer, {
    metadata: {
      contentType: mimetype,
    },
  });

  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: '03-01-2500', // Long-lived URL for demo purposes
  });
  
  return url;
};
