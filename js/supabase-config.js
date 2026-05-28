const SUPABASE_URL = 'https://ecefqmcvgcuohsvmydsm.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjZWZxbWN2Z2N1b2hzdm15ZHNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5MjQyOTcsImV4cCI6MjA5NTUwMDI5N30.v0QRf8VA2hUB0utBCu2JHWBfgX_L4dtxku2eHWRdMqU';

// ============================================
// DO NOT edit below this line
// ============================================

var sb = null;

function initSupabase() {
  var lib = window.supabase || window.supabaseJs;
  if (!lib || !lib.createClient) return false;
  sb = lib.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  return true;
}

function supabaseStorageUrl(bucket, path) {
  return SUPABASE_URL + '/storage/v1/object/public/' + bucket + '/' + path;
}