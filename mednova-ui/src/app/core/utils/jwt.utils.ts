export function extractRolesFromToken(accessToken: string): string[] {
  try {
    const payload = accessToken.split('.')[1];
    if (!payload) return [];
    const decoded = JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')));
    const roles = decoded.roles;
    return Array.isArray(roles) ? roles.map(String) : [];
  } catch {
    return [];
  }
}
