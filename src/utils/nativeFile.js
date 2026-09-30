// Helpers for saving files on the Android app (Capacitor). Web behaviour is untouched.
import { Capacitor } from '@capacitor/core';
import { Filesystem, Directory } from '@capacitor/filesystem';
import toast from 'react-hot-toast';

export const isNative = () => Capacitor.isNativePlatform();

// data: base64 string (no data: prefix). Saves to Documents/BillPro, falls back to app storage.
export async function saveBase64Native(filename, base64) {
  try {
    await Filesystem.writeFile({
      path: `BillPro/${filename}`,
      data: base64,
      directory: Directory.Documents,
      recursive: true,
    });
    toast.success(`Saved: Documents/BillPro/${filename}`, { duration: 5000 });
  } catch (e) {
    try {
      await Filesystem.writeFile({
        path: `BillPro/${filename}`,
        data: base64,
        directory: Directory.External,
        recursive: true,
      });
      toast.success(`Saved in app files: BillPro/${filename}`, { duration: 5000 });
    } catch (e2) {
      toast.error('Could not save file: ' + (e2?.message || e?.message || 'unknown error'));
    }
  }
}

export async function saveTextNative(filename, text) {
  // base64-encode UTF-8 text (keep BOM so Excel reads ₹ etc. correctly)
  const bytes = new TextEncoder().encode('\uFEFF' + text);
  let bin = '';
  bytes.forEach(b => { bin += String.fromCharCode(b); });
  return saveBase64Native(filename, btoa(bin));
}
