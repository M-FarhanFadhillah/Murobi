@extends('layouts.tempNav')
@section('container')
<div class="row">
    <div class="col-sm-6 .col-sm-8"><a href="#"><button type="button" class="btn btn-outline-warning"><i class="fa-solid fa-plus"></i> Tambah Banner</button></a></div>
    <div class="col-6 .col-sm-4"><h3><i class="fa-solid fa-sign-hanging"></i> Banner</h3></div>
</div>
<hr>
<div class="container">
    <table class="table text-center">
        <h3>Banner Aktif</h3>
        <thead>
            <th scope="col">No</th>
            <th scope="col">ID</th>
            <th scope="col">Judul</th>
            <th scope="col">Aksi</th>
        </thead>
        <tbody class="table-group-divider">
            <tr>
                <td>1</td>
                <td>2057051017</td>
                <td>Syahril Fajri Pratama</td>
                <td>
                    <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                        <a href="#"><button type="button" class="btn btn-outline-info"><i class="fa-solid fa-info"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-danger"><i class="fa-solid fa-trash"></i></button></a>
                    </div>
                </td>
            </tr>
        </tbody>
    </table>
    <table class="table text-center">
        <h3>Banner Non Aktif</h3>
        <thead>
            <th scope="col">No</th>
            <th scope="col">ID</th>
            <th scope="col">Judul</th>
            <th scope="col">Aksi</th>
        </thead>
        <tbody class="table-group-divider">
            <tr>
                <td>1</td>
                <td>2057051017</td>
                <td>Syahril Fajri Pratama</td>
                <td>
                    <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                        <a href="#"><button type="button" class="btn btn-outline-info"><i class="fa-solid fa-info"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-success"><i class="fa-solid fa-check"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-danger"><i class="fa-solid fa-trash"></i></button></a>
                    </div>
                </td>
            </tr>
        </tbody>
    </table>

</div> 
@endsection