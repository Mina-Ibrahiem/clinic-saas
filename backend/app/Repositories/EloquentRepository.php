<?php

namespace App\Repositories;

use App\Repositories\Contracts\RepositoryInterface;
use Illuminate\Database\Eloquent\Model;

/**
 * @template TModel of Model
 * @implements RepositoryInterface<TModel>
 */
abstract class EloquentRepository implements RepositoryInterface
{
    public function __construct(
        protected Model $model
    ) {
    }

    public function find(int|string $id): ?Model
    {
        return $this->model->newQuery()->find($id);
    }
}
