@extends('layouts.tempNav')
@section('container')
<div class="row">
    <div class="col-6 .col-sm-4"><h3><i class="fa-solid fa-sign-hanging"></i> Banner</h3></div>
    <div class="col text-end"><a href="#" data-bs-toggle="modal" data-bs-target="#addBanner"><button type="button" class="btn btn-outline-warning"><i class="fa-solid fa-plus"></i> Tambah Banner</button></a></div>
</div>
<hr>
<div class="container">
    <div class="row">
        <div class="col">
            <table class="table text-center">
                <h3>Banner Aktif</h3>
                <thead>
                    <th scope="col">ID</th>
                    <th scope="col">Judul</th>
                    <th scope="col">Aksi</th>
                </thead>
                <tbody class="table-group-divider">
                    @foreach ($aktif as $item)
                    <tr>
                        <td>{{ $item->id }}</td>
                        <td>{{ $item->judul }}</td>
                        <td>
                            <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                                <a href="#"data-bs-toggle="modal" data-bs-target="#infoBanner-{{ $item->id }}"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-info"></i></button></a>
                                <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Banner"><i class="fa-solid fa-trash"></i></button></a>
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        <div class="col">
            <table class="table text-center">
                <h3>Banner Non Aktif</h3>
                <thead>
                    <th scope="col">ID</th>
                    <th scope="col">Judul</th>
                    <th scope="col">Aksi</th>
                </thead>
                <tbody class="table-group-divider">
                    @foreach ($non as $item)
                    <tr>
                        <td>{{ $item->id }}</td>
                        <td>{{ $item->judul }}</td>
                        <td>
                            <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                                <a href="#" data-bs-toggle="modal" data-bs-target="#infoBanner-{{ $item->id }}"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-info"></i></button></a>
                                <a href="#"><button type="button" class="btn btn-outline-success" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Aktifkan Banner"><i class="fa-solid fa-check"></i></button></a>
                                <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Banner"><i class="fa-solid fa-trash"></i></button></a>
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div> 
{{-- Modal Details --}}
@foreach ($data as $item)
<div class="modal fade" id="infoBanner-{{ $item->id }}" tabindex="-1" aria-labelledby="infoBannerLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="infoBannerLabel">Detail Informasi</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <div class="col text-center mt-2">
                <img src="https://github.com/mdo.png" alt="Foto Profil" width="150">
            </div>
            <div class="col text-center">
                {{ $item->deskripsi }}
            </div>
            <div class="row">
                <div class="col">
                    <table class="table text-center">
                        <thead>
                        </thead>
                        <tbody>
                            <tr>
                                <th scope="row">ID</th>
                                <td>{{ $item->id }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Judul</th>
                                <td>{{ $item->judul }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Kategori</th>
                                <td>@switch($item->kategori)
                                    @case(0)
                                    Informatif
                                    @break
                                    @case(1)
                                    Promo
                                    @break
                                    @case(3)
                                    Kegiatan
                                    @break
                                    @endswitch
                                </td>
                            </tr>
                            <tr>
                                <th scope="row">Status</th>
                                <td>{{ ($item->status === true) ? 'Aktif ' : 'Nonaktif' }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endforeach 
{{-- Modal Tambah Masjid --}}
<div class="modal fade" id="addBanner" tabindex="-1" aria-labelledby="addBannerLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="addBannerLabel">Tamnah Banner</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
            <form>
                <div class="mb-3">
                  <label for="InputEmail1" class="form-label">Email address</label>
                  <input type="email" class="form-control" id="InputEmail1" aria-describedby="emailHelp">
                </div>
                <div class="mb-3">
                  <label for="InputName1" class="form-label">Nama</label>
                  <input type="text" class="form-control" id="InputName1" aria-describedby="nameHelp">
                </div>
                <div class="mb-3">
                  <label for="InputHP1" class="form-label">No. HP</label>
                  <input type="text" class="form-control" id="InputHP1" aria-describedby="HPHelp">
                </div>
                <div class="mb-3">
                    <label for="formFile" class="form-label">Foto Profil</label>
                    <input class="form-control" type="file" id="formFile">
                  </div>
                <div class="mb-3">
                  <label for="InputPassword1" class="form-label">Password</label>
                  <input type="password" class="form-control" id="InputPassword1">
                </div>
                <button type="submit" class="btn btn-primary">Submit</button>
              </form>
        </div>
      </div>
    </div>
</div>
@endsection