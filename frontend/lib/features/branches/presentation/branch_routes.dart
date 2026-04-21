abstract final class BranchRoutes {
  static const list = '/branches';
  static const create = '/branches/new';
  static String detail(int id) => '/branches/$id';
  static String edit(int id) => '/branches/$id/edit';
}
