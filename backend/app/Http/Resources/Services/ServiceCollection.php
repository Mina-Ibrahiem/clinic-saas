<?php

namespace App\Http\Resources\Services;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\ResourceCollection;

class ServiceCollection extends ResourceCollection
{
    public $collects = ServiceResource::class;

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \Illuminate\Pagination\LengthAwarePaginator|\Illuminate\Pagination\Paginator $paginator */
        $paginator = $this->resource;

        return [
            'items' => $this->collection,
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total' => method_exists($paginator, 'total') ? $paginator->total() : $this->collection->count(),
                'last_page' => method_exists($paginator, 'lastPage') ? $paginator->lastPage() : 1,
                'from' => method_exists($paginator, 'firstItem') ? $paginator->firstItem() : null,
                'to' => method_exists($paginator, 'lastItem') ? $paginator->lastItem() : null,
            ],
        ];
    }
}
